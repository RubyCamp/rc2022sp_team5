# 敵キャラクタ
class Enemy
	attr_accessor :mesh, :expired

	# 初期化
	def initialize(x: nil, y: nil, z: nil)
		# 初期位置指定が無ければランダムに配置する
		x ||= rand(100) / 10.0 - 0.5
		y ||= rand(10) / 10.0 + 1
		z ||= rand(10) / 10.0 + 3
		pos = Mittsu::Vector3.new(x, y, -z)
		texture = Mittsu::ImageUtils.load_texture('images/gost_simple_red.png')
		self.mesh = MeshFactory.create_enemy(r: 0.25, map:texture)
		self.mesh.position = pos
		self.expired = false
		mesh.rotate_y(-90)
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
			self.mesh.position.x += 0.03
		when 2
			self.mesh.position.x -= 0.03
		end

		case dy
		when 1
			self.mesh.position.y += 0.03
		when 2
			self.mesh.position.y -= 0.03
		end
	end
end