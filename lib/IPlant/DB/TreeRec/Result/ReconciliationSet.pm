package IPlant::DB::TreeRec::Result::ReconciliationSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

IPlant::DB::TreeRec::Result::ReconciliationSet

=cut

__PACKAGE__->table("reconciliation_set");

=head1 ACCESSORS

=head2 reconciliation_set_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "reconciliation_set_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("reconciliation_set_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-04-13 15:17:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:imbNlUSPeBaAvbDCP8fKfw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
