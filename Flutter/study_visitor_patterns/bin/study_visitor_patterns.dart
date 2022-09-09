import 'package:study_visitor_patterns/study_visitor_patterns.dart'
    as study_visitor_patterns;

abstract class BookmarkReferenceVisitor<T> {
  T forId(BookmarkReferenceId item);

  T forSlug(BookmarkReferenceSlug item);
}

class SimpleBookmarkReferenceVisitor<T> implements BookmarkReferenceVisitor<T> {
  final T Function(BookmarkReferenceId) idHandler;
  final T Function(BookmarkReferenceSlug) slugHandler;

  const SimpleBookmarkReferenceVisitor({
    required this.idHandler,
    required this.slugHandler,
  });

  @override
  T forId(BookmarkReferenceId item) => idHandler(item);

  @override
  T forSlug(BookmarkReferenceSlug item) => slugHandler(item);
}

abstract class BookmarkReferenceType {
  T accept<T>(BookmarkReferenceVisitor<T> visitor);
}

class BookmarkReferenceId extends BookmarkReferenceType {
  final int value;

  BookmarkReferenceId(this.value);

  @override
  T accept<T>(BookmarkReferenceVisitor<T> visitor) {
    return visitor.forId(this);
  }
}

class BookmarkReferenceSlug extends BookmarkReferenceType {
  final String value;

  BookmarkReferenceSlug(this.value);

  @override
  T accept<T>(BookmarkReferenceVisitor<T> visitor) {
    return visitor.forSlug(this);
  }
}

void main(List<String> arguments) {
  final parameter = {};

  BookmarkReferenceId id = BookmarkReferenceId(1);
  BookmarkReferenceSlug slug = BookmarkReferenceSlug('slug');

  BookmarkReferenceVisitor<void> visitor = SimpleBookmarkReferenceVisitor(
    idHandler: (id) => parameter['id'] = id.value,
    slugHandler: (slug) => parameter['id'] = slug.value,
  );

  // id.accept(visitor);
  slug.accept(visitor);

  print(parameter);
}
