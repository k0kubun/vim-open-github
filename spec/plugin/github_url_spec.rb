require "spec_helper"

describe GithubUrl do
  let(:github_url) { described_class.new(start_line, end_line, file_name) }

  describe "#generate" do
    subject { github_url.generate }

    before do
      allow(github_url).to receive(:repository_root).and_return(repo_root)
      allow(github_url).to receive(:remote_origin).and_return(remote_origin)
      allow(github_url).to receive(:current_branch).and_return(current_branch)
    end

    context "when no visual mode or selecting one line" do
      let(:start_line) { 2 }
      let(:end_line)   { 2 }
      let(:repo_root)  { "/Users/k0kubun/src/github.com/k0kubun/vim-open-github" }
      let(:remote_origin) { "git@github.com:/k0kubun/vim-open-github.git" }
      let(:current_branch) { 'master' }

      context "when bufname is relative" do
        let(:file_name)  { "plugin/open-github.vim" }

        it "returns proper GitHub url" do
          expect(subject).to eq("https://github.com/k0kubun/vim-open-github/blob/master/plugin/github_url.rb#L2")
        end
      end

      next
      context "when bufname is absolute" do
        let(:file_name)  { "/Users/k0kubun/src/github.com/k0kubun/vim-open-github/plugin/open-github.vim" }

        it "returns proper GitHub url" do
          expect(subject).to eq("https://github.com")
        end
      end
    end
  end
end
