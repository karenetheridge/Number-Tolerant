use strict;
use warnings;
package Number::Tolerant::Constant;
# ABSTRACT: a blessed constant type

=head1 SYNOPSIS

 use Number::Tolerant;
 use Number::Tolerant::Constant;

 my $range  = tolerance(10);
 ref $range; # "Number::Tolerant" -- w/o ::Constant, would be undef

=head1 DESCRIPTION

When Number::Tolerant is about to return a tolerance with zero variation, it
will return a constant instead.  This module will register a constant type that
will catch these constants and return them as Number::Tolerant objects.

I wrote this module to make it simpler to use tolerances with Class::DBI, which
would otherwise complain that the constructor hadn't returned a blessed object.

=cut

package
  Number::Tolerant::Type::constant_obj;
use parent qw(Number::Tolerant::Type);

sub construct { shift;
  { value => $_[0], min => $_[0], max => $_[0], constant => 1 }
};

sub parse {
  my ($self, $string, $factory) = @_;
  my $number = $self->number_re;
  return $factory->new($string) if ($string =~ m!\A($number)\z!);
  return;
}

sub numify { $_[0]->{value} }

sub stringify { "$_[0]->{value}" }

sub valid_args {
  my $self = shift;
  my $number = $self->normalize_number($_[0]);

  return unless defined $number;

  return $number if @_ == 1;

  return;
}

package Number::Tolerant::Constant;

sub import {
  Number::Tolerant->disable_plugin("Number::Tolerant::Type::constant");
  Number::Tolerant->enable_plugin( "Number::Tolerant::Type::constant_obj");
}

sub _disable {
  Number::Tolerant->disable_plugin("Number::Tolerant::Type::constant_obj");
  Number::Tolerant->enable_plugin( "Number::Tolerant::Type::constant");
}

1;
