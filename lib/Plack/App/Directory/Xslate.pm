package Plack::App::Directory::Xslate;
use strict;
use warnings;
our $VERSION = '0.01';

use parent qw(Plack::App::Directory);
use Text::Xslate;
use Plack::Util::Accessor qw(xslate_opt xslate_path);
use Encode;

sub new{
	my $class = shift;
	my $self  = $class->SUPER::new(@_);

	$self->xslate_opt->{suffix} = '.html'; 
	$self->xslate_opt->{path}   = $self->root;
	$self->{xslate} = Text::Xslate->new($self->xslate_opt);
	$self->{encoder} = find_encoding('utf-8');

	return $self;
}

{
	no strict 'refs';
	no warnings 'redefine';
	my $orig = \&Plack::App::File::serve_path;
	*Plack::App::File::serve_path = sub{
        my($self, $env) = @_;

		my $match = 0;

		my $path_match = $self->xslate_path;
		if($path_match){
			$match = 1;
			for my $path ($env->{SCRIPT_NAME}){
				unless(('CODE' eq ref($path_match)) ? $path_match->($path) : $path =~ $path_match){
					$match = 0;
					last;
				}
			}
		}

		return $match ?
			[
				200,
				['Content-Type' => 'text/html'],
				[$self->{encoder}->encode(
				     $self->{xslate}->render($env->{SCRIPT_NAME}, +{})
				)]
			]:  
			$orig->(@_);
	}
}

1; 
__END__ 

=head1 NAME

Plack::App::Directory::Xslate - Serve static files and Text::Xslate template files from document root with directory index

=head1 SYNOPSIS

# app.psgi
use Plack::App::Directory::Xslate;
my $app = Plack::App::Directory::Xslate->new({
    root => "/path/to/htdocs",
    xslate_opt  => +{ # Text::Xslate->new()
        syntax => 'TTerse',
    },
    xslate_path => qr{\.tt$},
 })->to_app;

=head1 DESCRIPTION

This is a static files and Text::Xslate template files server PSGI application with directory index a la Apache's mod_autoindex.

=head1 CONFIGURATION

=over 4

=item root

Document root directory. Defaults to the current directory.

=item xslate_opt

Text::Xslate constructor option.

=item xslate_path : Regexp or CodeRef

Allow Text::Xslate rendering path.

=back

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

L<Plack::App::Directory>
L<Plack::App::File>
L<Plack::App::Xslate>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
