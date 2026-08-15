class Gnanambot < Formula
  desc "Local macOS agent: Ollama chat + tools (shell, files, computer control) in Go"
  homepage "https://github.com/gnanam1990/gnanambot"
  url "https://github.com/gnanam1990/gnanambot/releases/download/v0.1.1/gnanambot-src.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "bffc43a460bd3026a08b913762cd2d59b6fab09142d5b9ceded8c4fa44dca986"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", "-o", bin/"gnanambot", "./cmd/gnanambot"
    (bin/"bin").install "bin/cwebp", "bin/sand-scroll"
    system "swiftc", "-O", "bin/ocr.swift", "-o", bin/"bin/ocr"
    system "swiftc", "-O", "bin/voice.swift", "-o", bin/"bin/voice"
    chmod "+x", bin/"bin/ocr", bin/"bin/voice"
  end

  service do
    run [opt_bin/"gnanambot", "-data", var/"gnanambot"]
    keep_alive true
    log_path var/"log/gnanambot.log"
    error_log_path var/"log/gnanambot.err.log"
  end

  test do
    system "#{bin}/gnanambot", "-version"
  end
end
