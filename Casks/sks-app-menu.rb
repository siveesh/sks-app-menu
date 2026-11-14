cask "sks-app-menu" do
  version "1.3.0"
  sha256 "7fba6495ce0ef214b2ec40dd4af69382713e3f8feb163ad35bb1622837c6decd"

  url "https://github.com/siveesh/sks-app-menu/releases/download/v#{version}/SKsAppMenu-#{version}-arm64.dmg"
  name "SK's App Menu"
  desc "Menu-bar and Dock application launcher with categories and app grids"
  homepage "https://github.com/siveesh/sks-app-menu"

  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "SK's App Menu.app"

  uninstall quit: "com.siveesh.sksappmenu"

  caveats <<~EOS
    This release is Developer ID-signed but is not notarized.
    macOS Gatekeeper may prevent opening a downloaded copy.
    See https://github.com/siveesh/sks-app-menu/blob/main/docs/Notarization.md
  EOS
end
