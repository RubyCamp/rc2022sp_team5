class Enemy
	attr_accessor :mesh, :expired

	# 初期化
	def initialize(radius, textures)
		x = rand(30) - 15
		y = rand(3) + 3
		z = rand(30) - 15
		pos = Mittsu::Vector3.new(x, y, -z)
		index = rand(2)
		self.mesh = MeshFactory.create_enemy(r: radius, map:textures[index])
		self.mesh.position = pos
		self.expired = false
	end

	# メッシュの現在位置を返す
	def position
		self.mesh.position
	end

	# 1フレーム分の進行処理
	def play(tank_position)
		dx = rand(3)
		dy = rand(3)
		case dx
		when 1
			self.mesh.position.x += 0.1
		when 2
			self.mesh.position.x -= 0.1
		end

		case dy
		when 1
			self.mesh.position.y += 0.02
		when 2
			self.mesh.position.y -= 0.02
		end

		# 常に戦車を見る
		self.mesh.look_at(tank_position)
		self.mesh.rotate_y(Math::PI*3/2)
	end
end