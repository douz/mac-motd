class MacMotd < Formula
  desc "Modular zsh MOTD for macOS"
  homepage "https://github.com/douz/mac-motd"
  url "__TARBALL_URL__"
  sha256 "__TARBALL_SHA256__"
__FORMULA_REVISION_LINE__
  license "MIT"

  depends_on "figlet"
  depends_on "ical-buddy"
  depends_on "ismc"
  depends_on "jq"
  depends_on "smartmontools"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/mac-motd" => "mac-motd"
  end

  def caveats
    <<~EOS
      Run:
        mac-motd install

      This creates user config at:
        ~/.douz.io/motd_config.zsh

      To refresh the config template safely:
        mac-motd install --refresh-config

      To uninstall:
        mac-motd uninstall
      or remove config too:
        mac-motd uninstall --purge-config
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/mac-motd", 1)
  end
end
