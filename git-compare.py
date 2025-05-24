import subprocess


def git_rev_list(git_dir, objects):
    """
    Get all objects in the git repository at git_dir.
    """
    cmdline = ['git', '--git-dir', git_dir, 'rev-list', '--all']
    if objects:
        cmdline.append('--objects')
    rev_list_all = subprocess.check_output(cmdline)
    rev_list_all = rev_list_all.splitlines()
    if objects:
        return {r.split(b' ', 1)[0]: r for r in rev_list_all}
    return set(rev_list_all)


class GitContents:
    def __init__(self, git_dir):
        self.git_dir = git_dir
        self.revs = git_rev_list(git_dir, objects=False)
        self.objects = git_rev_list(git_dir, objects=True)

    def is_equals_to(self, other):
        return self.objects == other.objects and self.revs == other.revs

    def is_contained_in(self, other):
        return len(self.revs - other.revs) == 0 and \
                len(set(self.objects.keys()) - set(other.objects.keys())) == 0

    def compare(self, other):
        if self.is_equals_to(other): return f'{self.git_dir} is the same as {other.git_dir}'
        if self.is_contained_in(other): return f'{self.git_dir} is contained in {other.git_dir}'
        if other.is_contained_in(self): return f'{other.git_dir} is contained in {self.git_dir}'
        return f'{self.git_dir} and {other.git_dir} are different'


def main(args):
    if len(args) != 2:
        print("Usage: git-compare.py <git_dir1> <git_dir2>")
        return 1

    dir1 = args[0]
    dir2 = args[1]

    gc1 = GitContents(dir1)
    gc2 = GitContents(dir2)

    print(gc1.compare(gc2))

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv[1:]))
