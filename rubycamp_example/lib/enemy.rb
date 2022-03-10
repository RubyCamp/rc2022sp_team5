# 敵キャラクタ
class Enemy
	attr_accessor :mesh, :expired

	# 初期化
	def initialize(x: nil, y: nil, z: nil)
		# 初期位置指定が無ければランダムに配置する
		x ||= rand(30) - 15
		y ||= rand(2) + 3
		z ||= rand(30) - 15
		pos = Mittsu::Vector3.new(x, y, -z)
		self.mesh = MeshFactory.create_enemy(r: 0.2, color: 0x00ff00)
		self.mesh.position = pos
		self.expired = false
	end

	# メッシュの現在位置を返す
	def position
		self.mesh.position
	end

	# 1フレーム分の進行処理
	def play
		dx = rand(3)
		dy = rand(3)
		case dx
		when 1
			self.mesh.position.x += 0.05
		when 2
			self.mesh.position.x -= 0.05
		end

		case dy
		when 1
			self.mesh.position.y += 0.02
		when 2
			self.mesh.position.y -= 0.02
		end
	end
end