package Dist::Zilla::Plugin::LicenseFile;
# ABSTRACT: Ship the repository's committed LICENSE, and keep it honest

use Moose;
with 'Dist::Zilla::Role::FileMunger';

use namespace::autoclean;

=head1 SYNOPSIS

  ; in dist.ini — note that @Basic's License plugin has to go, it would
  ; generate a second LICENSE and the build would abort
  [@Filter]
  -bundle = @Basic
  -remove = License

  [LicenseFile]

Then write the file once and commit it:

  dzil genlicense
  git add LICENSE && git commit

=head1 DESCRIPTION

L<Dist::Zilla> generates C<LICENSE> into the build by default, which means the
file exists in the tarball on CPAN but never in the repository. Hosting
platforms only see the repository: GitHub, Gitea and Forgejo all detect and
link a licence from a committed C<LICENSE> file, so a distribution built the
default way shows up as unlicensed on its own project page.

The fix is to commit the file and let C<GatherDir> pick it up like any other
source file. That works, but it silently rots: nothing connects the committed
text to the C<license>, C<copyright_holder> and C<copyright_year> settings in
F<dist.ini> any more. Bump the year, switch the licence, and the repository
keeps shipping last year's text.

This plugin closes that gap. On every build it checks the C<LICENSE> that was
gathered from the repository against the text L<Software::License> derives from
the distribution's own metadata, and refuses to build when the file is missing
or no longer matches. The companion command L<dzil genlicense|Dist::Zilla::App::Command::genlicense>
writes the file the check expects.

The plugin never writes or modifies anything itself — the committed file is
shipped verbatim, and a build either passes the check or stops.

=attr required

Whether a failing check aborts the build. Defaults to true.

Set it to C<0> to log the same complaint as a warning and carry on — useful
while migrating an existing distribution, where the first build is the thing
that tells you the file is missing.

  [LicenseFile]
  required = 0

=cut

has required => (
  is      => 'ro',
  isa     => 'Bool',
  default => 1,
);

=method filename

The name of the file, C<LICENSE>. A class method, so that
L<Dist::Zilla::App::Command::genlicense> writes the file this plugin looks for.

=method comparable

Normalises licence text for comparison, and is likewise a class method shared
with the command. Only whitespace at the very end of the text is forgiven — an
editor adding a final newline is not drift, any other difference is.

Both halves have to agree on this, or a distribution can end up in a state
where C<dzil genlicense> reports the file as current and the build still
rejects it.

=cut

sub filename { 'LICENSE' }

sub comparable {
  my ($self, $text) = @_;
  $text =~ s{\s+\z}{};
  return $text;
}

sub munge_files {
  my ($self) = @_;

  my $filename = $self->filename;
  my ($file) = grep { $_->name eq $filename } @{ $self->zilla->files };

  unless ($file) {
    return $self->_complain(
      "no $filename in the distribution: run 'dzil genlicense' and commit the file"
    );
  }

  my $wanted = $self->zilla->license->fulltext;

  unless ($self->comparable($file->content) eq $self->comparable($wanted)) {
    return $self->_complain(
      "$filename is out of date: it no longer matches the license, "
      . "copyright_holder and copyright_year in dist.ini. "
      . "Run 'dzil genlicense' and commit the file"
    );
  }

  $self->log_debug("$filename matches the distribution metadata");

  return;
}

sub _complain {
  my ($self, $message) = @_;
  return $self->required ? $self->log_fatal($message) : $self->log($message);
}

__PACKAGE__->meta->make_immutable;
1;

=head1 SEE ALSO

=for :list
* L<Dist::Zilla::App::Command::genlicense> — writes the file this plugin checks
* L<Dist::Zilla::Plugin::License> — the default plugin, which generates C<LICENSE> into the build instead

=cut
