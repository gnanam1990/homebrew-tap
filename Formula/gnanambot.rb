class Gnanambot < Formula
  desc "Local macOS agent: Ollama chat + tools (shell, files, computer control) in Go"
  homepage "https://github.com/gnanam1990/gnanambot"

  # Private-repo download strategy: Homebrew's core strategies can't fetch
  # from a private GitHub repo. This nested class overrides `_curl_args` and
  # appends the user's token (HOMEBREW_GITHUB_API_TOKEN) as a Bearer header.
  # Defined INSIDE the formula class so the `using:` line resolves it.
  class GnanambotPrivateTarball < CurlDownloadStrategy
    private

    def _curl_args
      args = super
      if (token = ENV["HOMEBREW_GITHUB_API_TOKEN"]) && !token.empty?
        args += ["--header", "Authorization: Bearer #{token}"]
      end
      args
    end
  end

  url "https://github.com/gnanam1990/gnanambot/archive/refs/tags/v0.1.3.tar.gz",
      using: GnanambotPrivateTarball
  sha256 "57f77e310f6efd598cc453c74ec9dd15007cd32b7d4cc67d61b5befe19173cef"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-X main.version=v0.1.3", "-o", bin/"gnanambot", "./cmd/gnanambot"
    system "go", "build", "-tags", "dev", "-ldflags", "-X main.version=v0.1.3", "-o", bin/"gnanambot-desktop", "./cmd/gnanambot-desktop"
    (bin/"bin").install "bin/cwebp", "bin/sand-scroll"
    system "swiftc", "-O", "bin/ocr.swift", "-o", bin/"bin/ocr"
    system "swiftc", "-O", "bin/voice.swift", "-o", bin/"bin/voice"
    chmod "+x", bin/"gnanambot", bin/"gnanambot-desktop"
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
