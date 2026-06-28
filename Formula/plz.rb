class Plz < Formula
  desc "Terminal assistant you pipe through, powered by Claude"
  homepage "https://github.com/zachdaniel/plz"
  url "https://github.com/zachdaniel/plz/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/zachdaniel/plz.git", branch: "main"

  def install
    bin.install "plz"
  end

  def caveats
    <<~EOS
      plz shells out to the `claude` CLI, which must be installed and
      authenticated separately: https://docs.claude.com/claude-code

      To make plz pipeline-aware (so it knows what you pipe from / to), wire up
      your shell:

        zsh — add to ~/.zshrc:
          eval "$(plz init zsh)"

        nushell — generate the glue once, then source it:
          plz init nu | save -f ($nu.default-config-dir | path join plz.nu)
          # then add to your config.nu:
          source plz.nu
    EOS
  end

  test do
    assert_match "usage: plz init", shell_output("#{bin}/plz init 2>&1", 1)
    assert_match "preexec", shell_output("#{bin}/plz init zsh")
    assert_match "def --wrapped plz", shell_output("#{bin}/plz init nu")
  end
end
