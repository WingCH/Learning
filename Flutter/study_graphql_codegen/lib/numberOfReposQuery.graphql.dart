import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Query$FetchRepositories {
  factory Variables$Query$FetchRepositories({required int number_of_repos}) =>
      Variables$Query$FetchRepositories._({
        r'number_of_repos': number_of_repos,
      });

  Variables$Query$FetchRepositories._(this._$data);

  factory Variables$Query$FetchRepositories.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$number_of_repos = data['number_of_repos'];
    result$data['number_of_repos'] = (l$number_of_repos as int);
    return Variables$Query$FetchRepositories._(result$data);
  }

  Map<String, dynamic> _$data;

  int get number_of_repos => (_$data['number_of_repos'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$number_of_repos = number_of_repos;
    result$data['number_of_repos'] = l$number_of_repos;
    return result$data;
  }

  CopyWith$Variables$Query$FetchRepositories<Variables$Query$FetchRepositories>
      get copyWith => CopyWith$Variables$Query$FetchRepositories(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Query$FetchRepositories) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$number_of_repos = number_of_repos;
    final lOther$number_of_repos = other.number_of_repos;
    if (l$number_of_repos != lOther$number_of_repos) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$number_of_repos = number_of_repos;
    return Object.hashAll([l$number_of_repos]);
  }
}

abstract class CopyWith$Variables$Query$FetchRepositories<TRes> {
  factory CopyWith$Variables$Query$FetchRepositories(
    Variables$Query$FetchRepositories instance,
    TRes Function(Variables$Query$FetchRepositories) then,
  ) = _CopyWithImpl$Variables$Query$FetchRepositories;

  factory CopyWith$Variables$Query$FetchRepositories.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FetchRepositories;

  TRes call({int? number_of_repos});
}

class _CopyWithImpl$Variables$Query$FetchRepositories<TRes>
    implements CopyWith$Variables$Query$FetchRepositories<TRes> {
  _CopyWithImpl$Variables$Query$FetchRepositories(
    this._instance,
    this._then,
  );

  final Variables$Query$FetchRepositories _instance;

  final TRes Function(Variables$Query$FetchRepositories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? number_of_repos = _undefined}) =>
      _then(Variables$Query$FetchRepositories._({
        ..._instance._$data,
        if (number_of_repos != _undefined && number_of_repos != null)
          'number_of_repos': (number_of_repos as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$FetchRepositories<TRes>
    implements CopyWith$Variables$Query$FetchRepositories<TRes> {
  _CopyWithStubImpl$Variables$Query$FetchRepositories(this._res);

  TRes _res;

  call({int? number_of_repos}) => _res;
}

class Query$FetchRepositories {
  Query$FetchRepositories({
    required this.viewer,
    this.$__typename = 'Query',
  });

  factory Query$FetchRepositories.fromJson(Map<String, dynamic> json) {
    final l$viewer = json['viewer'];
    final l$$__typename = json['__typename'];
    return Query$FetchRepositories(
      viewer: Query$FetchRepositories$viewer.fromJson(
          (l$viewer as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FetchRepositories$viewer viewer;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$viewer = viewer;
    _resultData['viewer'] = l$viewer.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$viewer = viewer;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$viewer,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$FetchRepositories) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$viewer = viewer;
    final lOther$viewer = other.viewer;
    if (l$viewer != lOther$viewer) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FetchRepositories on Query$FetchRepositories {
  CopyWith$Query$FetchRepositories<Query$FetchRepositories> get copyWith =>
      CopyWith$Query$FetchRepositories(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$FetchRepositories<TRes> {
  factory CopyWith$Query$FetchRepositories(
    Query$FetchRepositories instance,
    TRes Function(Query$FetchRepositories) then,
  ) = _CopyWithImpl$Query$FetchRepositories;

  factory CopyWith$Query$FetchRepositories.stub(TRes res) =
      _CopyWithStubImpl$Query$FetchRepositories;

  TRes call({
    Query$FetchRepositories$viewer? viewer,
    String? $__typename,
  });
  CopyWith$Query$FetchRepositories$viewer<TRes> get viewer;
}

class _CopyWithImpl$Query$FetchRepositories<TRes>
    implements CopyWith$Query$FetchRepositories<TRes> {
  _CopyWithImpl$Query$FetchRepositories(
    this._instance,
    this._then,
  );

  final Query$FetchRepositories _instance;

  final TRes Function(Query$FetchRepositories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? viewer = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$FetchRepositories(
        viewer: viewer == _undefined || viewer == null
            ? _instance.viewer
            : (viewer as Query$FetchRepositories$viewer),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$FetchRepositories$viewer<TRes> get viewer {
    final local$viewer = _instance.viewer;
    return CopyWith$Query$FetchRepositories$viewer(
        local$viewer, (e) => call(viewer: e));
  }
}

class _CopyWithStubImpl$Query$FetchRepositories<TRes>
    implements CopyWith$Query$FetchRepositories<TRes> {
  _CopyWithStubImpl$Query$FetchRepositories(this._res);

  TRes _res;

  call({
    Query$FetchRepositories$viewer? viewer,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$FetchRepositories$viewer<TRes> get viewer =>
      CopyWith$Query$FetchRepositories$viewer.stub(_res);
}

const documentNodeQueryFetchRepositories = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'FetchRepositories'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'number_of_repos')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'viewer'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'name'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'repositories'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'last'),
                value: VariableNode(name: NameNode(value: 'number_of_repos')),
              )
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'nodes'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'name'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Query$FetchRepositories _parserFn$Query$FetchRepositories(
        Map<String, dynamic> data) =>
    Query$FetchRepositories.fromJson(data);
typedef OnQueryComplete$Query$FetchRepositories = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$FetchRepositories?,
);

class Options$Query$FetchRepositories
    extends graphql.QueryOptions<Query$FetchRepositories> {
  Options$Query$FetchRepositories({
    String? operationName,
    required Variables$Query$FetchRepositories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FetchRepositories? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FetchRepositories? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$FetchRepositories(data),
                  ),
          onError: onError,
          document: documentNodeQueryFetchRepositories,
          parserFn: _parserFn$Query$FetchRepositories,
        );

  final OnQueryComplete$Query$FetchRepositories? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$FetchRepositories
    extends graphql.WatchQueryOptions<Query$FetchRepositories> {
  WatchOptions$Query$FetchRepositories({
    String? operationName,
    required Variables$Query$FetchRepositories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FetchRepositories? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryFetchRepositories,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$FetchRepositories,
        );
}

class FetchMoreOptions$Query$FetchRepositories
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FetchRepositories({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FetchRepositories variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryFetchRepositories,
        );
}

extension ClientExtension$Query$FetchRepositories on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FetchRepositories>> query$FetchRepositories(
          Options$Query$FetchRepositories options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$FetchRepositories> watchQuery$FetchRepositories(
          WatchOptions$Query$FetchRepositories options) =>
      this.watchQuery(options);
  void writeQuery$FetchRepositories({
    required Query$FetchRepositories data,
    required Variables$Query$FetchRepositories variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryFetchRepositories),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$FetchRepositories? readQuery$FetchRepositories({
    required Variables$Query$FetchRepositories variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryFetchRepositories),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FetchRepositories.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$FetchRepositories>
    useQuery$FetchRepositories(Options$Query$FetchRepositories options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$FetchRepositories>
    useWatchQuery$FetchRepositories(
            WatchOptions$Query$FetchRepositories options) =>
        graphql_flutter.useWatchQuery(options);

class Query$FetchRepositories$Widget
    extends graphql_flutter.Query<Query$FetchRepositories> {
  Query$FetchRepositories$Widget({
    widgets.Key? key,
    required Options$Query$FetchRepositories options,
    required graphql_flutter.QueryBuilder<Query$FetchRepositories> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$FetchRepositories$viewer {
  Query$FetchRepositories$viewer({
    this.name,
    required this.repositories,
    this.$__typename = 'User',
  });

  factory Query$FetchRepositories$viewer.fromJson(Map<String, dynamic> json) {
    final l$name = json['name'];
    final l$repositories = json['repositories'];
    final l$$__typename = json['__typename'];
    return Query$FetchRepositories$viewer(
      name: (l$name as String?),
      repositories: Query$FetchRepositories$viewer$repositories.fromJson(
          (l$repositories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final String? name;

  final Query$FetchRepositories$viewer$repositories repositories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$repositories = repositories;
    _resultData['repositories'] = l$repositories.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$repositories = repositories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$repositories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$FetchRepositories$viewer) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$repositories = repositories;
    final lOther$repositories = other.repositories;
    if (l$repositories != lOther$repositories) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FetchRepositories$viewer
    on Query$FetchRepositories$viewer {
  CopyWith$Query$FetchRepositories$viewer<Query$FetchRepositories$viewer>
      get copyWith => CopyWith$Query$FetchRepositories$viewer(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$FetchRepositories$viewer<TRes> {
  factory CopyWith$Query$FetchRepositories$viewer(
    Query$FetchRepositories$viewer instance,
    TRes Function(Query$FetchRepositories$viewer) then,
  ) = _CopyWithImpl$Query$FetchRepositories$viewer;

  factory CopyWith$Query$FetchRepositories$viewer.stub(TRes res) =
      _CopyWithStubImpl$Query$FetchRepositories$viewer;

  TRes call({
    String? name,
    Query$FetchRepositories$viewer$repositories? repositories,
    String? $__typename,
  });
  CopyWith$Query$FetchRepositories$viewer$repositories<TRes> get repositories;
}

class _CopyWithImpl$Query$FetchRepositories$viewer<TRes>
    implements CopyWith$Query$FetchRepositories$viewer<TRes> {
  _CopyWithImpl$Query$FetchRepositories$viewer(
    this._instance,
    this._then,
  );

  final Query$FetchRepositories$viewer _instance;

  final TRes Function(Query$FetchRepositories$viewer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? repositories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$FetchRepositories$viewer(
        name: name == _undefined ? _instance.name : (name as String?),
        repositories: repositories == _undefined || repositories == null
            ? _instance.repositories
            : (repositories as Query$FetchRepositories$viewer$repositories),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$FetchRepositories$viewer$repositories<TRes> get repositories {
    final local$repositories = _instance.repositories;
    return CopyWith$Query$FetchRepositories$viewer$repositories(
        local$repositories, (e) => call(repositories: e));
  }
}

class _CopyWithStubImpl$Query$FetchRepositories$viewer<TRes>
    implements CopyWith$Query$FetchRepositories$viewer<TRes> {
  _CopyWithStubImpl$Query$FetchRepositories$viewer(this._res);

  TRes _res;

  call({
    String? name,
    Query$FetchRepositories$viewer$repositories? repositories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$FetchRepositories$viewer$repositories<TRes> get repositories =>
      CopyWith$Query$FetchRepositories$viewer$repositories.stub(_res);
}

class Query$FetchRepositories$viewer$repositories {
  Query$FetchRepositories$viewer$repositories({
    this.nodes,
    this.$__typename = 'RepositoryConnection',
  });

  factory Query$FetchRepositories$viewer$repositories.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$FetchRepositories$viewer$repositories(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$FetchRepositories$viewer$repositories$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$FetchRepositories$viewer$repositories$nodes?>? nodes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$nodes == null ? null : Object.hashAll(l$nodes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$FetchRepositories$viewer$repositories) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes != null && lOther$nodes != null) {
      if (l$nodes.length != lOther$nodes.length) {
        return false;
      }
      for (int i = 0; i < l$nodes.length; i++) {
        final l$nodes$entry = l$nodes[i];
        final lOther$nodes$entry = lOther$nodes[i];
        if (l$nodes$entry != lOther$nodes$entry) {
          return false;
        }
      }
    } else if (l$nodes != lOther$nodes) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FetchRepositories$viewer$repositories
    on Query$FetchRepositories$viewer$repositories {
  CopyWith$Query$FetchRepositories$viewer$repositories<
          Query$FetchRepositories$viewer$repositories>
      get copyWith => CopyWith$Query$FetchRepositories$viewer$repositories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$FetchRepositories$viewer$repositories<TRes> {
  factory CopyWith$Query$FetchRepositories$viewer$repositories(
    Query$FetchRepositories$viewer$repositories instance,
    TRes Function(Query$FetchRepositories$viewer$repositories) then,
  ) = _CopyWithImpl$Query$FetchRepositories$viewer$repositories;

  factory CopyWith$Query$FetchRepositories$viewer$repositories.stub(TRes res) =
      _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories;

  TRes call({
    List<Query$FetchRepositories$viewer$repositories$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$FetchRepositories$viewer$repositories$nodes?>? Function(
              Iterable<
                  CopyWith$Query$FetchRepositories$viewer$repositories$nodes<
                      Query$FetchRepositories$viewer$repositories$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$FetchRepositories$viewer$repositories<TRes>
    implements CopyWith$Query$FetchRepositories$viewer$repositories<TRes> {
  _CopyWithImpl$Query$FetchRepositories$viewer$repositories(
    this._instance,
    this._then,
  );

  final Query$FetchRepositories$viewer$repositories _instance;

  final TRes Function(Query$FetchRepositories$viewer$repositories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$FetchRepositories$viewer$repositories(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes
                as List<Query$FetchRepositories$viewer$repositories$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$FetchRepositories$viewer$repositories$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$FetchRepositories$viewer$repositories$nodes<
                          Query$FetchRepositories$viewer$repositories$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$FetchRepositories$viewer$repositories$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories<TRes>
    implements CopyWith$Query$FetchRepositories$viewer$repositories<TRes> {
  _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories(this._res);

  TRes _res;

  call({
    List<Query$FetchRepositories$viewer$repositories$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$FetchRepositories$viewer$repositories$nodes {
  Query$FetchRepositories$viewer$repositories$nodes({
    required this.name,
    this.$__typename = 'Repository',
  });

  factory Query$FetchRepositories$viewer$repositories$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Query$FetchRepositories$viewer$repositories$nodes(
      name: (l$name as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$FetchRepositories$viewer$repositories$nodes) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FetchRepositories$viewer$repositories$nodes
    on Query$FetchRepositories$viewer$repositories$nodes {
  CopyWith$Query$FetchRepositories$viewer$repositories$nodes<
          Query$FetchRepositories$viewer$repositories$nodes>
      get copyWith =>
          CopyWith$Query$FetchRepositories$viewer$repositories$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$FetchRepositories$viewer$repositories$nodes<
    TRes> {
  factory CopyWith$Query$FetchRepositories$viewer$repositories$nodes(
    Query$FetchRepositories$viewer$repositories$nodes instance,
    TRes Function(Query$FetchRepositories$viewer$repositories$nodes) then,
  ) = _CopyWithImpl$Query$FetchRepositories$viewer$repositories$nodes;

  factory CopyWith$Query$FetchRepositories$viewer$repositories$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories$nodes;

  TRes call({
    String? name,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$FetchRepositories$viewer$repositories$nodes<TRes>
    implements
        CopyWith$Query$FetchRepositories$viewer$repositories$nodes<TRes> {
  _CopyWithImpl$Query$FetchRepositories$viewer$repositories$nodes(
    this._instance,
    this._then,
  );

  final Query$FetchRepositories$viewer$repositories$nodes _instance;

  final TRes Function(Query$FetchRepositories$viewer$repositories$nodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$FetchRepositories$viewer$repositories$nodes(
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories$nodes<TRes>
    implements
        CopyWith$Query$FetchRepositories$viewer$repositories$nodes<TRes> {
  _CopyWithStubImpl$Query$FetchRepositories$viewer$repositories$nodes(
      this._res);

  TRes _res;

  call({
    String? name,
    String? $__typename,
  }) =>
      _res;
}
