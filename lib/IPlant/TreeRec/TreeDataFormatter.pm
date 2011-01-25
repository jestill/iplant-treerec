package IPlant::TreeRec::TreeDataFormatter;

use 5.008000;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Bio::Tree::NodeNHX;
use Bio::TreeIO;
use Carp;
use Class::Std::Utils;
use Readonly;

{
    ##########################################################################
    # Usage      : $formatter = $IPlant::TreeRec::TreeDataFormatter->new();
    #
    # Purpose    : Initializes a new tree data formatter.
    #
    # Returns    : The new formatter.
    #
    # Parameters : None.
    #
    # Throws     : No exceptions.
    sub new {
        my ($class) = @_;

        # Create the new object.
        my $self = bless anon_scalar, $class;

        return $self;
    }

    ##########################################################################
    # Usage      : $data_ref = $formatter->format_tree($tree);
    #
    # Purpose    : Formats the tree as a Perl data structure consisting of
    #              nested hashes.
    #
    # Returns    : The data structure representing the tree.
    #
    # Parameters : $tree - the tree to format.
    #
    # Throws     : No exceptions.
    sub format_tree {
        my ( $self, $tree ) = @_;

        # Build and return the tree.
        return {
            'tree' => {
                'id'   => $tree->id(),
                'root' => $self->_build_node( $tree->get_root_node() ),
            },
        };
    }

    ##########################################################################
    # Usage      : $root_ref = $formatter->_build_node($root);
    #
    # Purpose    : Builds the output for a single tree node.
    #
    # Returns    : The formatted node.
    #
    # Parameters : $node - the node.
    #
    # Throws     : No exceptions.
    sub _build_node {
        my ( $self, $node ) = @_;

        # Build the list of children.
        my @children;
        for my $child ( $node->each_Descendent() ) {
            push @children, $self->_build_node($child);
        }

        # Build the formatted node.
        my $formatted_node = {
            'id'       => scalar $node->get_tag_values('ID'),
            'children' => \@children,
        };

        # Add the name if there is one.
        my $name = $node->id();
        if ( defined $name ) {
            $formatted_node->{name} = $name;
        }

        # Add the values of any NHX tags that we support.
        $self->_add_supported_tags( $node, $formatted_node );

        return $formatted_node;
    }

    # The NHX tags that we support, indexed by the corresponding field name.
    Readonly my %NHX_TAG_FOR => {
        'edgeDependencies' => 'EDGEDUPS',
        'nodeDependencies' => 'NODEDUPS',
    };

    ##########################################################################
    # Usage      : $formatter->_add_supported_tags( $node, $formatted_node );
    #
    # Purpose    : Adds the values of supported NHX tags to a formatted node.
    #
    # Returns    : Nothing.
    #
    # Parameters : $node           - the node from the actual tree.
    #              $formatted_node - the formatted node.
    #
    # Throws     : No exceptions.
    sub _add_supported_tags {
        my ( $self, $node, $formatted_node ) = @_;

        # Add any NHX tags that we support.
        for my $field_name ( keys %NHX_TAG_FOR ) {
            my $tag_name = $NHX_TAG_FOR{$field_name};
            my $field_value = scalar $node->get_tag_values($tag_name);
            if ( defined $field_value ) {
                $formatted_node->{$field_name} = $field_value;
            }
        }

        return;
    }
}

1;
__END__