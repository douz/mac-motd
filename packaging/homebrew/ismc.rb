class Ismc < Formula
  desc "Apple SMC information tool"
  homepage "https://github.com/dkorunic/iSMC"
  url "https://github.com/dkorunic/iSMC/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "21b14179c5e25648e4647b131704d3b2959091bff18f9a237847fd5c53efcc95"
  license "GPL-3.0-only"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(output: bin/"iSMC"), "."
  end

  test do
    assert_match "Apple SMC information tool", shell_output("#{bin}/iSMC --help")
  end
end
