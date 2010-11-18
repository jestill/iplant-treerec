package IPlant::TreeRec::REST::API::download::type::qualifier;

use 5.008000;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Class::Std::Utils;
use IPlant::TreeRec::REST::Handler;
use IPlant::TreeRec::REST::Initializer qw(get_tree_rec);
use Readonly;

# The getter subroutines for the various object types.
Readonly my %GETTER_FOR =>
    ( 'default' => sub { $_[0]->get_file( $_[1], $_[2] ) }, );

use base 'IPlant::TreeRec::REST::Handler';

{
    my %type_of;
    my %qualifier_of;

    ##########################################################################
    # Usage      : $handler = IPlant::TreeRec::REST::API::download::type
    #                  ::qualifier->new( $type, $qualifier );
    #
    # Purpose    : Creates a new handler.
    #
    # Returns    : The new handler.
    #
    # Parameters : $type - the search type.
    #
    # Throws     : No exceptions.
    sub new {
        my ( $class, $type, $qualifier ) = @_;

        # Create the new object.
        my $self = $class->SUPER::new();

        # Set the object properties.
        $type_of{ ident $self }      = $type;
        $qualifier_of{ ident $self } = $qualifier;

        return $self;
    }

    ##########################################################################
    # Usage      : N/A
    #
    # Purpose    : Cleans up after an instance of this class has gone out of
    #              scope.
    #
    # Returns    : Nothing.
    #
    # Parameters : None.
    #
    # Throws     : No exceptions.
    sub DESTROY {
        my ($self) = @_;

        # Clean up.
        delete $type_of{ ident $self };
        delete $qualifier_of{ ident $self };

        return;
    }

    ##########################################################################
    # Usage      : $handler->GET( $request, $response );
    #
    # Purpose    : Handles a GET request.
    #
    # Returns    : An HTTP OK staus code.
    #
    # Parameters : $request  - the request.
    #              $response - the response.
    #
    # Throws     : No exceptions.
    sub GET {
        my ( $self, $request, $response ) = @_;

        # Get the tree reconciliation object.
        my $treerec = get_tree_rec($request);

        # Extract the object type and qualifier.
        my $object_type = $type_of{ ident $self };
        my $qualifier   = $qualifier_of{ ident $self };

        # Get the subroutine for object retrieval.
        my $getter_ref = $GETTER_FOR{$object_type}
            || $GETTER_FOR{default};

        # Retrieve the object.
        my $object = $getter_ref->( $treerec, $object_type, $qualifier );

        # Set the output according to the object.
        if ( $self->_object_is_file($object) ) {
            $self->_create_file_response( $request, $response, $object );
        }
        else {
            $self->_create_json_response( $request, $response, $object );
        }

        return Apache2::Const::HTTP_OK;
    }

    ##########################################################################
    # Usage      : $is_file
    #                  = $handler->_object_is_file($object);
    #
    # Purpose    : Determines whether or not the given object appears to be
    #              a file returned by our file retriever.
    #
    # Returns    : True if the object appears to be a file.
    #
    # Parameters : $object - the object to check.
    #
    # Throws     : No exceptions.
    sub _object_is_file {
        my ( $self, $object ) = @_;
        return ref $object eq 'HASH' && exists $object->{filename} ? 1 : 0;
    }

    ##########################################################################
    # Usage      : $handler->_create_file_response( $request, $response,
    #                  $object );
    #
    # Purpose    : Creates the appropriate response for a file object.
    #
    # Returns    : Nothing.
    #
    # Parameters : $request  - the request.
    #              $respones - the response object.
    #              $object   - the object being returned.
    #
    # Throws     : No exceptions.
    sub _create_file_response {
        my ( $self, $request, $response, $object ) = @_;

        # Set up the response object.
        $request->requestedFormat('bin');
        $response->bin( $object->{contents} );
        $response->binMimeType( $object->{content_type} );

        # Set the content disposition header.
        my $filename = $object->{filename};
        $request->headers_out()
            ->set(
            'Content-Disposition' => "attachment; filename=$filename" );

        return;
    }

    ##########################################################################
    # Usage      : $handler->_create_json_response( $request, $response,
    #                  $object );
    #
    # Purpose    : Creates the appropriate response for a JSON object.
    #
    # Returns    : Nothing.
    #
    # Parameters : $request  - the request.
    #              $respones - the response object.
    #              $object   - the object being returned.
    #
    # Throws     : No exceptions.
    sub _create_json_response {
        my ( $self, $request, $response, $object ) = @_;

        # Set up the response object.
        $request->requestedFormat('json');
        $response->data()->{item} = $object;

        return;
    }
}

1;
__END__
