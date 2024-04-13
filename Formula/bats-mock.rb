class BatsMock < Formula
  desc 'Mocking/stubbing library for BATS'
  homepage 'https://github.com/buildkite-plugins/bats-mock'
  url 'https://github.com/buildkite-plugins/bats-mock/archive/refs/tags/v2.1.1.tar.gz'
  sha256 'f3a00111ae0ee3a3e397619b041eee2f0a7af583fc00311e4fc6deca35337266'
  license 'MIT'
  head 'https://github.com/buildkite-plugins/bats-mock.git', branch: 'master'

  def install
    mkdir 'bats-mock'
    mv 'binstub', 'bats-mock/'
    mv 'stub.bash', 'bats-mock/'
    mv 'tests', 'bats-mock/'
    lib.install 'bats-mock'
  end

  def caveats
    <<~EOS
      To load the bats-mock lib in your bats test:

          load '#{HOMEBREW_PREFIX}/lib/bats-mock/stub.bash'
    EOS
  end

  test do
    (testpath / 'test.bats').write <<~EOS
      setup() {
        load '#{HOMEBREW_PREFIX}/lib/bats-mock/stub.bash'
      }

      function teardown() {
          # Just clean up
          unstub --allow-missing mycommand
      }

      # Uncomment to enable stub debug output:
      # export MYCOMMAND_STUB_DEBUG=/dev/tty

      @test "Stub a single command with basic arguments" {
        stub mycommand "llamas : echo running llamas"

        run mycommand llamas

        [ "$status" -eq 0 ]
        [[ "$output" == *"running llamas"* ]]

        unstub mycommand
      }

      @test "Stub a command with multiple invocations" {
        stub mycommand \
          "llamas : echo running llamas" \
          "alpacas : echo running alpacas"

        run bash -c "mycommand llamas && mycommand alpacas"

        [ "$status" -eq 0 ]
        [[ "$output" == *"running llamas"* ]]
        [[ "$output" == *"running alpacas"* ]]

        unstub mycommand
      }
    EOS
    ENV['TEST_DEPS_DIR'] = "#{HOMEBREW_PREFIX}/lib"
    system 'bats', 'test.bats'
  end
end
