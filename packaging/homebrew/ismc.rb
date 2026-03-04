class Ismc < Formula
  desc "Apple SMC information tool"
  homepage "https://github.com/dkorunic/iSMC"
  url "https://github.com/dkorunic/iSMC/releases/download/v0.11.1/iSMC_Darwin_all.tar.gz"
  sha256 "c1e44a2b6d56b27f34b23e9a4e254f0c52bbb1d30e2fdb0fdd80fa219ef2ac13"
  license "GPL-3.0-only"

  def install
    bin.install "iSMC"
  end

  test do
    assert_match "Apple SMC information tool", shell_output("#{bin}/iSMC --help")
  end
end
