use inc::Module::Install;
use inc::Module::Install::Metadata;
name 'Plack-App-Directory-Xslate';
all_from 'lib/Plack/App/Directory/Xslate.pm';
readme_from 'lib/Plack/App/Directory/Xslate.pm';
readme_pod_from 'lib/Plack/App/Directory/Xslate.pm';
githubmeta;

requires 'parent';
requires 'Encode';
requires 'Text::Xslate';
requires 'Plack::App::Directory';
requires 'Plack::Util::Accessor';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
