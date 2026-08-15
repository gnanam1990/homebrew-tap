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

  url "https://github.com/gnanam1990/gnanambot/archive/refs/tags/v0.1.1.tar.gz",
      using: GnanambotPrivateTarball
  sha256 "05c9505027c4e9033eb7f2428cfbe631cf348096d56857db76c6643d11b4ba70"
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
