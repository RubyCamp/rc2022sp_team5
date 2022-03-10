# 弾丸モデル
class Bullet
	attr_accessor :mesh, :expired

	SPEED = -0.3 # 弾丸の速度
	FRAME_COUNT_UPPER_LIMIT = 3 * 60

	# 初期化
	# 進行方向を表す単位ベクトルを受領する
	def initialize(camera)
		self.mesh = MeshFactory.create_bullet(r: 0.02, color: 0xff0000)
		#TODO 球の位置とカメラ位置を合わせる  
		self.position.x = camera.position.x
		f = Mittsu::Vector4.new(0, 0, 1, 0)
		f.apply_matrix4(camera.matrix).normalize
		f.multiply_scalar(Bullet::SPEED)
		@forward_vector = f
		@forwarded_frame_count = 0 # 何フレーム分進行したかを記憶するカウンタ
		self.expired = false
	end

	# メッシュの現在位置を返す
	def position
		self.mesh.position
	end

	# １フレーム分の進行処理
	def play
		# オブジェクト生成時に渡された進行方向に向けて、単位ベクトル分だけ進む
		self.mesh.position.add(@forward_vector)

		@forwarded_frame_count += 1

		# 進行フレーム数が上限に達したら消滅フラグを立てる
		if @forwarded_frame_count > FRAME_COUNT_UPPER_LIMIT
			self.expired = true
		end
	end
end
