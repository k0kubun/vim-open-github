require "spec_helper"

describe GithubUrl do
  let!(:github_url) { described_class.new(start_line, end_line, file_name) }

  describe "#generate" do
    subject { github_url.generate }

    let(:start_line) { 1 }
    let(:end_line)   { 1 }
    let(:repo_root)  { `pwd`.strip }
    let(:target_file_path) { "/plugin/open-github.vim" }
    let(:file_name)  { "#{repo_root}#{target_file_path}" }
    let(:user) { `git config remote.origin.url`.strip.split('/')[-2] }
    let(:revision) { `git rev-parse --abbrev-ref @ | xargs git rev-parse`.strip }
    let(:github_repo_url) { "https://github.com/#{user}/vim-open-github/blob/#{revision}#{target_file_path}" }
    let(:remote_origin) { "git@github.com:/#{user}/vim-open-github.git" }

    before do
      allow(github_url).to receive(:repository_root).and_return(repo_root)
      allow(github_url).to receive(:remote_origin).and_return(remote_origin)
    end

    it { is_expected.to eq("#{github_repo_url}#L1") }

    describe "line anchor" do
      context "when not visual mode or selecting one line" do
        let(:start_line) { 2 }
        let(:end_line) { 2 }

        it "returns url highlighted one line" do
          expect(subject).to eq("#{github_repo_url}#L2")
        end
      end

      context "when selecting multiple lines" do
        let(:start_line) { 2 }
        let(:end_line) { 8 }

        it "returns url highlighted one line" do
          expect(subject).to eq("#{github_repo_url}#L2-L8")
        end
      end
    end

    describe "url scheme" do
      context "when url starts with https://" do
        let(:remote_origin) { "https://github.com/#{user}/vim-open-github.git" }

        it { is_expected.to eq("#{github_repo_url}#L1") }
      end

      context "when url does not contain user" do
        let(:remote_origin) { "github.com:/#{user}/vim-open-github.git" }

        it { is_expected.to eq("#{github_repo_url}#L1") }
      end
    end

    describe "host" do
      context "when host is GitHub Enterprise" do
        let(:remote_origin) { "ghe.example.co:k0kubun/vim-open-github.git" }

        it { is_expected.to eq("https://ghe.example.co/k0kubun/vim-open-github/blob/#{revision}/plugin/open-github.vim#L1") }
      end
    end

    describe "bufname" do
      let(:file) { "README.md" }
      context "when bufname is relative path" do
        let(:file_name) { file }
        let(:target_file_path) { "/#{file}" }

        it { is_expected.to eq("#{github_repo_url}#L1") }
      end

      context "when bufname is absolute path" do
        let(:target_file_path) { "/#{file}" }

        it { is_expected.to eq("#{github_repo_url}#L1") }
      end
    end

    context 'given argument' do
      subject { github_url.generate(version) }
      let(:version) { 'v4.2.3' }

      it { is_expected.to eq("https://github.com/#{user}/vim-open-github/blob/#{version}#{target_file_path}#L1") }
    end
  end
end
