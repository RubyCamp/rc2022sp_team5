require_relative 'base'

module Directors
	# ゲーム本編のディレクター
	class GameDirector < Base
		CAMERA_ROTATE_SPEED_X = 0.015
		CAMERA_ROTATE_SPEED_Y = 0.015
		CAMERA_ROTATE_SPEED_Z = 0.015

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
		end

		# １フレーム分の進行処理
		def play

			# 現在発射済みの弾丸を一通り動かす
			@bullets.each(&:play)

			# 現在登場済みの敵を一通り動かす
			@enemies.each(&:play)

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
			if @frame_counter % 60 == 0
				enemy = Enemy.new
				@enemies << enemy
				self.scene.add(enemy.mesh)
			end

			@frame_counter += 1

			self.camera.rotate_x(CAMERA_ROTATE_SPEED_X) if self.renderer.window.key_down?(GLFW_KEY_W)
			self.camera.rotate_x(-CAMERA_ROTATE_SPEED_X) if self.renderer.window.key_down?(GLFW_KEY_S)
			self.camera.rotate_y(CAMERA_ROTATE_SPEED_Y) if self.renderer.window.key_down?(GLFW_KEY_A)
			self.camera.rotate_y(-CAMERA_ROTATE_SPEED_Y) if self.renderer.window.key_down?(GLFW_KEY_D)
			self.camera.rotate_z(CAMERA_ROTATE_SPEED_Z) if self.renderer.window.key_down?(GLFW_KEY_Q)
			self.camera.rotate_z(-CAMERA_ROTATE_SPEED_Z) if self.renderer.window.key_down?(GLFW_KEY_E)
			self.camera.position.x += 0.05 if self.renderer.window.key_down?(GLFW_KEY_RIGHT)
			self.camera.position.x -= 0.05 if self.renderer.window.key_down?(GLFW_KEY_LEFT)
		end

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			case glfw_key
				# SPACEキー押下で弾丸を発射
				when GLFW_KEY_SPACE
					shoot
			end
		end

		private

		# ゲーム本編の登場オブジェクト群を生成
		def create_objects
			@sun = LightFactory.create_sun_light
			self.scene.add(@sun)
			@earth = MeshFactory.create_earth
			@earth.position.y = -0.9
			@earth.position.z = -0.8
			self.scene.add(@earth)
		end

		# 弾丸発射
		def shoot
			# 弾丸オブジェクト生成
			bullet = Bullet.new(camera)
			self.scene.add(bullet.mesh)
			@bullets << bullet
		end

		# 弾丸と敵の当たり判定
		def hit_any_enemies(bullet)
			return if bullet.expired

			@enemies.each do |enemy|
				next if enemy.expired
				distance = bullet.position.distance_to(enemy.position)
				if distance < 0.2
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