# メッシュオブジェクトのファクトリー
# ゲーム内に登場するメッシュを生産する役割を一手に引き受ける
class MeshFactory
	# 弾丸の生成
	def self.create_bullet(r: 0.1, div_w: 16, div_h: 16, color: nil, map: nil, normal_map: nil)
		geometry = Mittsu::SphereGeometry.new(r, div_w, div_h)
		material = generate_material(:phong, color, map, normal_map)
		Mittsu::Mesh.new(geometry, material)
	end

	# 敵キャラクタの生成
	def self.create_enemy(r: 0.1, div_w: 16, div_h: 16, color: nil, map: nil, normal_map: nil)
		geometry = Mittsu::SphereGeometry.new(r, div_w, div_h)
		material = generate_material(:phong, color, map, normal_map)
		Mittsu::Mesh.new(geometry, material)
	end

	# 平面パネルの生成
	def self.create_panel(width: 1, height: 1, color: nil, map: nil)
		geometry = Mittsu::PlaneGeometry.new(width, height)
		material = generate_material(:basic, color, map, nil)
		Mittsu::Mesh.new(geometry, material)
	end

	# 地球の生成
	def self.create_earth
		geometry = Mittsu::BoxGeometry.new(50.0, 1.0, 50.0)
		material = generate_material(
			:phong,
			nil,
			TextureFactory.create_texture_map("desert.png"),
			TextureFactory.create_normal_map("desert-normal.png"))
		Mittsu::Mesh.new(geometry, material)
	end

	# 戦車の生成 
	def self.create_tank(scene, camera)
		loader = Mittsu::OBJMTLLoader.new
		object = loader.load('tank/tank.obj', 'tank.mtl')
		object.print_tree

		tank = Mittsu::Object3D.new
		body, wheels, turret, tracks, barrel = object.children.map { |o| o.children.first }
		object.children.each do |o|
		o.children.first.material.metal = true
		end
		[body, wheels, tracks].each do |o|
		tank.add(o)
		end

		turret.position.set(0.0, 0.17, -0.17)
		tank.add(turret)

		barrel.position.set(0.0, 0.05, 0.2)
		turret.add(barrel)

		geometry = Mittsu::PlaneGeometry.new(0.25, 0.25)
		texture_map = Mittsu::ImageUtils.load_texture("images/kurahashi-sann.png")
		material = Mittsu::MeshBasicMaterial.new(map: texture_map)
		mesh = Mittsu::Mesh.new(geometry, material)
		mesh.position.y = 0.15
		mesh.position.z = -0.1
		mesh.rotation.x = Math::PI/3
		mesh.rotation.y = Math::PI
		turret.add(mesh)

		tank.rotation.y = Math::PI

		barrel.add(camera)

		return tank, turret, barrel
	end

	# 汎用マテリアル生成メソッド
	def self.generate_material(type, color, map, normal_map)
		mat = nil
		args = {}
		args[:color] = color if color
		args[:map] = map if map
		args[:normal_map] = normal_map if normal_map
		case type
		when :basic
			mat = Mittsu::MeshBasicMaterial.new(args)

		when :lambert
			mat = Mittsu::MeshLambertMaterial.new(args)

		when :phong
			mat = Mittsu::MeshPhongMaterial.new(args)
		end
		mat
	end
end