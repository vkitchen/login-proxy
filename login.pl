#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Log;
use Mojolicious::Plugin::Authentication;

use Authen::Passphrase::BlowfishCrypt;

use Text::CSV;
use Data::Dumper;

my $log = Mojo::Log->new;

plugin 'authentication', {
    autoload_user => 1,
    load_user => sub {
        my $self = shift;
        my $uid = shift;

        my $csv = Text::CSV->new({ sep_char => ':' });
        $csv->column_names (qw( username password uid ));
        open(my $data, '<', 'shadow') or die "Could not open 'shadow' $!\n";
        my @db = @{$csv->getline_hr_all($data)};
        close($data);

        foreach my $user (@db) {
            return $user if $uid eq %$user{'uid'};
        }
        return undef;
    },
    validate_user => sub {
        my $self = shift;
        my $username = shift || '';
        my $password = shift || '';
        my $extradata = shift || {};

        my $csv = Text::CSV->new({ sep_char => ':' });
        $csv->column_names (qw( username password uid ));
        open(my $data, '<', 'shadow') or die "Could not open 'shadow' $!\n";
        my @db = @{$csv->getline_hr_all($data)};
        close($data);

        foreach my $user (@db) {
            if ($username eq %$user{'username'}) {
                my $crypt = %$user{'password'};
                my $ppr = Authen::Passphrase::BlowfishCrypt->
                    from_rfc2307($crypt);
                if ($ppr->match($password)) {
                    return %$user{'uid'};
                } else {
                    return undef;
                }
            }
        }
        return undef;
    },
};

plugin 'proxy';

get '/' => sub {
    my $c = shift;
    if (! $c->is_user_authenticated) {
        $c->redirect_to('/login');
    }
    $c->render(template => 'index', user => $c->current_user);
};

get '/login' => sub {
    my $c = shift;
    if ($c->is_user_authenticated) {
        $c->redirect_to('/');
    }
    $c->render(template => 'login');
};

post '/login' => sub {
    my $c = shift;
    my $username = $c->param('username');
    my $password = $c->param('password');
    if ($c->authenticate($username, $password)) {
        $c->redirect_to('/');
    } else {
        $c->flash(message => 'Password or Username incorrect');
        $c->redirect_to('/login');
    }
};

get '/logout' => sub {
    my $c = shift;

    $c->logout();
    $c->redirect_to('/');
};

get '/app/' => sub {
    my $c = shift;
    if (! $c->is_user_authenticated) {
        $c->redirect_to('/login');
    }
    $c->proxy_to('http://localhost:8081/')
};

get '/*params' => sub {
    my $c = shift;
    if (! $c->is_user_authenticated) {
        $c->redirect_to('/login');
    }
    my $params = $c->stash('params');
    $c->proxy_to("http://localhost:8081/$params")
};

app->start;
