import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/mutations.dart';

class ChatRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<Map<String, dynamic>> updateGroupChat({
    required String chatId,
    String? name,
    String? description,
    String? photo,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.updateGroupChatMutation),
      variables: {
        'chatId': chatId,
        'name': name,
        'description': description,
        'photo': photo,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(
        result.exception?.graphqlErrors.first.message ??
            'Error updating group chat',
      );
    }

    return result.data?['updateGroupChat'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createGroupChat({
    required String name,
    String? description,
    required List<String> participantEmails,
    String? photo,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.createGroupChatMutation),
      variables: {
        'name': name,
        'description': description,
        'participantEmails': participantEmails,
        'photo': photo,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(
        result.exception?.graphqlErrors.first.message ??
            'Error creating group chat',
      );
    }

    return result.data?['createGroupChat'] as Map<String, dynamic>;
  }
}
