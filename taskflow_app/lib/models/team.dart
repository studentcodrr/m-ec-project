// lib/models/team_model.dart

class TeamMember {
  final String name;
  final String avatarUrl;

  TeamMember({required this.name, required this.avatarUrl});
}

class Team {
  final String title;
  final List<TeamMember> members;

  Team({required this.title, required this.members});
}