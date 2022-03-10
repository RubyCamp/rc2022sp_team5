# 弾丸モデル
class Bullet
	attr_accessor :mesh, :expired

	FRAME_COUNT_UPPER_LIMIT = 3 * 60

	# 初期化
	# 進行方向を表す単位ベクトルを受領する
	def initialize(forward_vector, position, radius)
		self.mesh = MeshFactory.create_bullet(r: radius, color: 0xff0000)
		self.mesh.position.set(position.x, position.y, position.z)
		@forward_vector = forward_vector
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
