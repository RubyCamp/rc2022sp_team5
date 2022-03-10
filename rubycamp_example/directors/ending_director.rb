require_relative 'base'

module Directors
	# エンディング画面用ディレクター
	class EndingDirector < Base
		# 初期化
		def initialize(screen_width:, screen_height:, renderer:)
			super

			# テキスト表示用パネルを生成し、カメラから程よい距離に配置する
			@description = AnimatedPanel.new(width: 1, height: 0.25, start_frame: 15, map: TextureFactory.create_ending_description)
			@description.mesh.position.z = -0.5
			self.scene.add(@description.mesh)

			@description1 = AnimatedPanel.new(width: 0.4, height: 0.1, start_frame: 15, map: TextureFactory.create_score_zannen_description)
			@description1.mesh.position.z = -0.5
			@description1.mesh.position.y = -0.2
			self.scene.add(@description1.mesh)

			@description2 = AnimatedPanel.new(width: 0.4, height: 0.1, start_frame: 15, map: TextureFactory.create_score_hutuu_description)
			@description2.mesh.position.z = -0.5
			@description2.mesh.position.y = -0.2
			self.scene.add(@description2.mesh)

			@description3 = AnimatedPanel.new(width: 0.4, height: 0.1, start_frame: 15, map: TextureFactory.create_score_sugoi_description)
			@description3.mesh.position.z = -0.5
			@description3.mesh.position.y = -0.2
			self.scene.add(@description3.mesh)
		end

		# 1フレーム分の進行処理
		def play
			# テキスト表示用パネルを1フレーム分アニメーションさせる
			@description.play
			if $cnt_sc >= 45 then
				@description1.play
			elsif $cnt_sc >= 30 then
				@description2.play
			else
				@description3.play
			end
		end

		# キー押下（単発）時のハンドリング
		def on_key_pressed(glfw_key:)
			case glfw_key
				# ESCキー押下で終了する
				when GLFW_KEY_ESCAPE
					puts "クリア!!"
					transition_to_next_director # self.next_directorがセットされていないのでメインループが終わる
			end
		end
	end
end