class Oneclient < Formula
  desc "Installs Oneclient, the Command Line tool for Onedata platform"
  homepage "https://onedata.org"
  url "https://github.com/onedata/oneclient.git", :branch => "release/18.02.0-beta1"
  version "18.02.0-beta1"
  head "https://github.com/onedata/oneclient.git", :branch => "develop"

  depends_on :macos => :sierra

  depends_on :osxfuse
  depends_on "libtool" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "boost"
  depends_on "boost-python" => :build
  depends_on "go" => :build
  depends_on "libsodium"
  depends_on "protobuf"
  depends_on "tbb"
  depends_on "poco"
  depends_on "double-conversion"
  depends_on "glog"
  depends_on "onedata/onedata/folly"
  depends_on "nss"
  depends_on "openssl"
  depends_on "libevent"
  depends_on "nspr"
  depends_on "aws-sdk-cpp"
  depends_on "onedata/onedata/swift-cpp-sdk"
  depends_on "onedata/onedata/libiberty"

  def install
    # Setup environment variables for the build
    ENV.prepend_path "PKG_CONFIG_PATH", "#{HOMEBREW_PREFIX}/opt/nss/lib/pkgconfig"

    # Setup make arguments
    args = %w[
      release
      WITH_COVERAGE=OFF
      WITH_CEPH=OFF
      WITH_S3=ON
      WITH_SWIFT=ON
      WITH_GLUSTERFS=OFF
      OPENSSL_ROOT_DIR=/usr/local/opt/openssl
      OPENSSL_LIBRARIES=/usr/local/opt/openssl/lib
    ]

    # Make release version
    system "make", *args

    # Set default Fuse options for macos
    fuse_mount_options = <<-EOS.undent
      fuse_mount_opt = allow_other
      fuse_mount_opt = defer_permissions
      fuse_mount_opt = fsname=oneclient
      fuse_mount_opt = volname=Oneclient
      fuse_mount_opt = kill_on_unmount
      fuse_mount_opt = noappledouble
      fuse_mount_opt = noapplexattr
    EOS
    inreplace "config/oneclient.conf", "# fuse_mount_opt =", fuse_mount_options

    # Install all files into the default Cellar
    bin.install "release/oneclient"
    man1.install "man/oneclient.1"
    man5.install "man/oneclient.conf.5"
    doc.install "LICENSE.txt"
    doc.install "README.md"
    bash_completion.install "autocomplete/osx/oneclient.bash-completion" => "oneclient"
    zsh_completion.install "autocomplete/osx/_oneclient"
    etc.install "config/oneclient.conf"
  end

  def caveats
    <<-EOS.undent

      This is an experimental version of Onedata `oneclient` command line tool
      for macOS.

      To mount your spaces on macOS add the following options to the `oneclient`
      command line or set them in the `/usr/local/etc/oneclient.conf` file:

        oneclient -o allow_other,defer_permissions,noappledouble,noapplexattr ...

      Additionally you can set the volume name (as displayed on desktop icon):

        -o volname=MyProvider

      For more information on `oneclient` usage check:

        man oneclient
    EOS
  end

  test do
    system "#{bin}/oneclient --version | grep Oneclient"
  end
end
