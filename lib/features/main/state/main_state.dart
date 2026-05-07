class MainState {
  final int selectedIndex;
  final bool showLanding;

  const MainState({this.selectedIndex = 0, this.showLanding = true});

  MainState copyWith({int? selectedIndex, bool? showLanding}) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      showLanding: showLanding ?? this.showLanding,
    );
  }
}
