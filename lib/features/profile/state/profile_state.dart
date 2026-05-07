class ProfileState {
  final String name;
  final String role;
  final bool loading;

  ProfileState({
    this.name = "",
    this.role = "",
    this.loading = true,
  });

  ProfileState copyWith({
    String? name,
    String? role,
    bool? loading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      role: role ?? this.role,
      loading: loading ?? this.loading,
    );
  }
}