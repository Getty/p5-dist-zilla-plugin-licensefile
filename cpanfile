requires 'Dist::Zilla', '6.037';
requires 'Dist::Zilla::App';
requires 'Dist::Zilla::Role::FileMunger';
requires 'Moose';
requires 'Path::Tiny';

on test => sub {
    requires 'Dist::Zilla::App::Tester';
    requires 'Dist::Zilla::Tester';
    requires 'File::Find::Rule';
    requires 'File::Temp';
    requires 'Path::Tiny';
    requires 'Test::DZil';
    requires 'Test::More';
};

on develop => sub {
    requires 'Dist::Zilla';
    requires 'Test::Pod';
};
