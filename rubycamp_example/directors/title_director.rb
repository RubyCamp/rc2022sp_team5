require_relative 'base'

module Directors
  # タイトル画面用ディレクター
  class TitleDirector < Base
    # 初期化
    def initialize(screen_width:, screen_height:, renderer:)
      super

      # タイトル画面の次に遷移するシーンのディレクターオブジェクトを用意
      self.next_director = GameDirector.new(screen_width: screen_width, screen_height: screen_height, renderer: renderer)

      # タイトル画面の登場オブジェクト群を生成
      create_objects
    end

    # １フレーム分の進行処理
    def play

      # タイトル文字パネル群をそれぞれ１フレーム分進行させる
      @panels.each(&:play)

      # 説明用文字パネルを１フレーム分進行させる
      @description.play
    end

    # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
      case glfw_key
        # SPACEキー押下で弾丸を発射
        when GLFW_KEY_SPACE
          puts "シーン遷移 → GameDirector"
          transition_to_next_director
      end
    end

    private

    # タイトル画面の登場オブジェクト群を生成
    def create_objects
      create_title_background
      # 太陽光をセット
      @sun = LightFactory.create_sun_light
      self.scene.add(@sun)

      # 背景用の地球を作成
      @earth = MeshFactory.create_earth
      @earth.position.z = -2
      self.scene.add(@earth)

      # タイトル文字パネルの初期表示位置（X座標）を定義
      start_x = -0.35

      # RubyCampの8文字を、1文字1アニメーションパネルとして作成し、表示開始タイミングを微妙にずらす
      %w(R u b y C a m p).each_with_index do |char, idx|
        create_title_logo(char, start_x + (idx * 0.1), idx * 2)
      end

      # 説明文字列用のパネル作成
      # タイトル画面表示開始から180フレーム経過で表示するように調整
      # 位置は適当に決め打ち
      @description = Panel.new(width: 1, height: 0.25, start_frame: 120, map: TextureFactory.create_title_description)
      @description.mesh.position.y = -0.25
      @description.mesh.position.z = -0.5
      self.scene.add(@description.mesh)
    end

    # タイトルロゴ用アニメーションパネル作成
    # タイトル画面の表示開始から30+delay_framesのフレームが経過してから、120フレーム掛けてアニメーションするよう設定
    def create_title_logo(char, x_pos, delay_frames)
      panel = AnimatedPanel.new(start_frame: 30 + delay_frames, duration: 120, map: TextureFactory.create_string(char))
      panel.mesh.position.x = x_pos
      panel.mesh.position.z = -0.5
      # self.scene.add(panel.mesh)
      @panels ||= []
      @panels << panel
    end

    def create_title_background()
      mesh = MeshFactory.create_panel(width: 1.8, height: 1.5, map: TextureFactory.create_title_background)
      mesh.position.z = -1
      self.scene.add(mesh)
    end
  end
end