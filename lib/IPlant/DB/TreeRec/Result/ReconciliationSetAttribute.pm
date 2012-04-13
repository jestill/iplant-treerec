package IPlant::DB::TreeRec::Result::ReconciliationSetAttribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

IPlant::DB::TreeRec::Result::ReconciliationSetAttribute

=cut

__PACKAGE__->table("reconciliation_set_attribute");

=head1 ACCESSORS

=head2 reconciliation_set_attribute_id

  data_type: 'integer'
  is_nullable: 0

=head2 reconciliation_set_id

  data_type: 'integer'
  is_nullable: 0

=head2 cvterm_id

  data_type: 'integer'
  is_nullable: 0

=head2 value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 rank

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 source_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "reconciliation_set_attribute_id",
  { data_type => "integer", is_nullable => 0 },
  "reconciliation_set_id",
  { data_type => "integer", is_nullable => 0 },
  "cvterm_id",
  { data_type => "integer", is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "rank",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "source_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("reconciliation_set_attribute_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-04-13 15:17:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/y0xOpKPITyF5W0iN0fUsA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
