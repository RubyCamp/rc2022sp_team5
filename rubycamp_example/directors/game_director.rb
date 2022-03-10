require_relative 'base'

module Directors
	# ゲーム本編のディレクター
	class GameDirector < Base
		TANK_SPEED = 0.05
		MOUSE_SENSITIVITY = 0.005
		BULLET_SPEAD = 0.3
		ENEMY_MAX = 10
		ENEMY_RADIUS = 0.5
		BULLET_RADIUS = 0.1


		# 初期化
		def initialize(screen_width:, screen_height:, renderer:)
			super

			# ゲーム本編の次に遷移するシーンのディレクターオブジェクトを用意
			self.next_director = EndingDirector.new(screen_width: screen_width, screen_height: screen_height, renderer: renderer)

			# ゲーム本編の登場オブジェクト群を生成
			create_objects

			# 弾丸の詰め合わせ用配列
			@bullets = []

			# 敵の詰め合わせ用配列
			@enemies = []

			# 現在のフレーム数をカウントする
			@frame_counter = 0

			#敵を倒した数の初期化
			@cnt = 0

			$cnt_sc = 0
		end

		# １フレーム分の進行処理
		def play
			# 現在発射済みの弾丸を一通り動かす
			@bullets.each(&:play)

			# 現在登場済みの敵を一通り動かす
			@enemies.each{|enemy| enemy.play(@temporary_tank.position)}

			# 各弾丸について当たり判定実施
			@bullets.each{|bullet| hit_any_enemies(bullet) }

			# 消滅済みの弾丸及び敵を配列とシーンから除去(わざと複雑っぽく記述しています)
			rejected_bullets = []
			@bullets.delete_if{|bullet| bullet.expired ? rejected_bullets << bullet : false }
			rejected_bullets.each{|bullet| self.scene.remove(bullet.mesh) }
			rejected_enemies = []
			@enemies.delete_if{|enemy| enemy.expired ? rejected_enemies << enemy : false }
			rejected_enemies.each{|enemy| self.scene.remove(enemy.mesh) }

			# 一定のフレーム数経過毎に敵キャラを出現させる
			if @frame_counter % 60 == 0 && @enemies.length < ENEMY_MAX
				enemy = Enemy.new(ENEMY_RADIUS, @enemy_textures)
				@enemies << enemy
				self.scene.add(enemy.mesh)
			end

			@frame_counter += 1

			# 移動処理
			drive_tank(TANK_SPEED) if self.renderer.window.key_down?(GLFW_KEY_W)
			drive_tank(-TANK_SPEED) if self.renderer.window.key_down?(GLFW_KEY_S)
			turn_tank(TANK_SPEED) if self.renderer.window.key_down?(GLFW_KEY_A)
			turn_tank(-TANK_SPEED) if self.renderer.window.key_down?(GLFW_KEY_D)
		end

		# マウスで視点操作
		def move_rotate()
			last_x = self.renderer.window.mouse_position.x
			last_y = self.renderer.window.mouse_position.y
			self.renderer.window.set_mouselock(true)
				self.renderer.window.on_mouse_move do |position|
				rotate_turret((last_x-position.x) * MOUSE_SENSITIVITY)
				lift_barrel((position.y-last_y) * MOUSE_SENSITIVITY)

				last_x = position.x
				last_y = position.y
			end
		end

		# 操作系の関数
		# 移動
		def drive_tank(amount)
			@tank.translate_z(amount)
			@temporary_tank.position.set(@tank.position.x, @tank.position.y, @tank.position.z)
		end
		
		# 回転
		def turn_tank(amount)
			@turret.rotation.y -= amount
			@tank.rotation.y += amount
		end

		# 視点(上下)
		def lift_barrel(amount)
			@barrel.rotation.x += amount
			# 移動範囲を超えた場合
			if @barrel.rotation.x > Math::PI/36.0
				@barrel.rotation.x = Math::PI/36.0
			elsif @barrel.rotation.x < -Math::PI/6.0
				@barrel.rotation.x = -Math::PI/6.0
			end
			@temporary_tank.rotation.x = @barrel.rotation.x
			# puts "#{-100*Math::sin(temporary_tank.rotation.y) + temporary_tank.position.x}, #{-100 * Math::tan(temporary_tank.rotation.x)}, #{-100*Math::cos(temporary_tank.rotation.y) + temporary_tank.position.z}"
		end

		# 視点(左右)
		def rotate_turret(amount)
			@turret.rotation.y += amount
			@temporary_tank.rotation.y += amount
		end

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			case glfw_key
				# SPACEキー押下で弾丸を発射
				when GLFW_KEY_SPACE
					shoot
				# Escキーで強制終了
				when GLFW_KEY_ESCAPE
					exit
			end
		end

		# ボタン押下（単発）時のハンドリング
		def on_mouse_button_pressed(glfw_mouse_button:)
			case glfw_mouse_button
				# 左クリックで弾丸を発射
				when GLFW_MOUSE_BUTTON_LEFT
					shoot
			end
		end

		private

		# ゲーム本編の登場オブジェクト群を生成
		def create_objects
			# 光源(太陽)
			@sun = LightFactory.create_sun_light
			self.scene.add(@sun)

			# 光源(スポットライト)
			@spot_light = LightFactory.create_spot_light
			self.scene.add(@spot_light)

			# 地面
			@earth = MeshFactory.create_earth
			@earth.position.y = -0.5
			self.scene.add(@earth)

			# 戦車を生成して配置
			@tank, @turret, @barrel = MeshFactory.create_tank(self.scene, self.camera)
			@temporary_tank = Mittsu::Object3D.new
			self.scene.add(@tank)

			self.camera.position.z = -3.0
			self.camera.position.y = 2.0
			self.camera.rotation.y = Math::PI
			self.camera.rotation.x = Math::PI/6.0

			# 背景
			cube_map_texture = Mittsu::ImageUtils.load_texture_cube(
				[ 'rt', 'lf', 'up', 'dn', 'bk', 'ft' ].map { |path|
				"images/alpha-island_#{path}.png"
				}
			)
			
			shader = Mittsu::ShaderLib[:cube]
			shader.uniforms['tCube'].value = cube_map_texture
			
			skybox_material = Mittsu::ShaderMaterial.new({
				fragment_shader: shader.fragment_shader,
				vertex_shader: shader.vertex_shader,
				uniforms: shader.uniforms,
				depth_write: false,
				side: Mittsu::BackSide
			})
			
			skybox = Mittsu::Mesh.new(Mittsu::BoxGeometry.new(100, 100, 100), skybox_material)
			scene.add(skybox)

			# 敵のテクスチャを読み込む
			@enemy_textures = [
				Mittsu::ImageUtils.load_texture('images/gost_simple_red.png'),
				Mittsu::ImageUtils.load_texture('images/gost_shadow_black.png')
			]

			# 視点操作の処理
			move_rotate()
		end

		# 弾丸発射
		def shoot
			# 現在カメラが向いている方向を進行方向とし、進行方向に対しBULLET_SPEAD分移動する単位単位ベクトルfを作成する
			f = Mittsu::Vector4.new(
				-1000 * Math::sin(@temporary_tank.rotation.y) + @temporary_tank.position.x,
				-1000 * Math::tan(@temporary_tank.rotation.x),
				-1000 * Math::cos(@temporary_tank.rotation.y) + @temporary_tank.position.z,
				1
			)
			f.apply_matrix4(@temporary_tank.matrix).normalize
			f.multiply_scalar(BULLET_SPEAD)

			# 弾丸オブジェクト生成
			bullet = Bullet.new(f, @temporary_tank.position, BULLET_RADIUS)
			self.scene.add(bullet.mesh)
			@bullets << bullet
			$cnt_sc += 1
		end

		# 弾丸と敵の当たり判定
		def hit_any_enemies(bullet)
			return if bullet.expired

			@enemies.each do |enemy|
				next if enemy.expired
				distance = bullet.position.distance_to(enemy.position)
				if distance < ENEMY_RADIUS + BULLET_RADIUS
					@cnt = @cnt + 1
					puts "Hit! #{@cnt}"
					bullet.expired = true
					enemy.expired = true
					
					if @cnt>=10
						puts "シーン遷移 → EndingDirector"
						transition_to_next_director
						break
					end
				end
			end
		end
	end
end