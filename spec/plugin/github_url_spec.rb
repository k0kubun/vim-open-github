require "spec_helper"

describe GithubUrl do
  let!(:github_url) { described_class.new(start_line, end_line, file_name) }

  describe "#generate" do
    subject { github_url.generate }

    let(:start_line) { 1 }
    let(:end_line)   { 1 }
    let(:repo_root)  { "/Users/k0kubun/src/github.com/k0kubun/vim-open-github" }
    let(:file_name)  { "/Users/k0kubun/src/github.com/k0kubun/vim-open-github/plugin/open-github.vim" }
    let(:remote_origin) { "git@github.com:/k0kubun/vim-open-github.git" }
    let(:current_branch) { "master" }

    before do
      allow(github_url).to receive(:repository_root).and_return(repo_root)
      allow(github_url).to receive(:remote_origin).and_return(remote_origin)
      allow(github_url).to receive(:current_branch).and_return(current_branch)
    end

    it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L1") }

    describe "line anchor" do
      context "when not visual mode or selecting one line" do
        let(:start_line) { 2 }
        let(:end_line) { 2 }

        it "returns url highlighted one line" do
          expect(subject).to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L2")
        end
      end

      context "when selecting multiple lines" do
        let(:start_line) { 2 }
        let(:end_line) { 8 }

        it "returns url highlighted one line" do
          expect(subject).to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L2-L8")
        end
      end
    end

    describe "url scheme" do
      context "when url starts with https://" do
        let(:remote_origin) { "https://github.com/k0kubun/vim-open-github.git" }

        it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L1") }
      end

      context "when url does not contain user" do
        let(:remote_origin) { "github.com:/k0kubun/vim-open-github.git" }

        it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L1") }
      end
    end

    describe "host" do
      context "when host is GitHub Enterprise" do
        let(:remote_origin) { "ghe.example.co:k0kubun/vim-open-github.git" }

        it { is_expected.to eq("https://ghe.example.co/k0kubun/vim-open-github/blob/master/plugin/open-github.vim#L1") }
      end
    end

    describe "bufname" do
      context "when bufname is relative path" do
        let(:file_name)  { "README.md" }

        it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/master/README.md#L1") }
      end

      context "when bufname is absolute path" do
        let(:file_name)  { "/Users/k0kubun/src/github.com/k0kubun/vim-open-github/README.md" }

        it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/master/README.md#L1") }
      end
    end

    describe "branch" do
      context "when current branch is not master" do
        let(:current_branch) { "development" }

        it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/development/plugin/open-github.vim#L1") }
      end
    end

    context 'given argument' do
      subject { github_url.generate('v4.2.3') }

      it { is_expected.to eq("https://github.com/k0kubun/vim-open-github/blob/v4.2.3/plugin/open-github.vim#L1") }
    end
  end
end
