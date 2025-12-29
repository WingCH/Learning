/// Mock 資料產生器
library;

import 'tournament_match.dart';

/// 產生測試用的錦標賽資料
class MockDataGenerator {
  /// 產生 8 隊標準錦標賽 (8強 → 決賽)
  static TournamentBracket generate8TeamBracket() {
    // 設定隊伍名稱
    const teams = [
      'Team Alpha',
      'Team Beta',
      'Team Gamma',
      'Team Delta',
      'Team Epsilon',
      'Team Zeta',
      'Team Eta',
      'Team Theta',
    ];

    // 第一輪 (8強): 4 場比賽
    final round1 = TournamentRound(
      roundIndex: 0,
      name: '8強賽',
      matches: [
        TournamentMatch(
          id: 'r0m0',
          teamA: teams[0],
          teamB: teams[1],
          scoreA: 3,
          scoreB: 1,
          winner: teams[0],
        ),
        TournamentMatch(
          id: 'r0m1',
          teamA: teams[2],
          teamB: teams[3],
          scoreA: 2,
          scoreB: 2,
        ),
        TournamentMatch(
          id: 'r0m2',
          teamA: teams[4],
          teamB: teams[5],
          scoreA: 0,
          scoreB: 3,
          winner: teams[5],
        ),
        TournamentMatch(
          id: 'r0m3',
          teamA: teams[6],
          teamB: teams[7],
          scoreA: 4,
          scoreB: 2,
          winner: teams[6],
        ),
      ],
    );

    // 第二輪 (4強): 2 場比賽
    final round2 = TournamentRound(
      roundIndex: 1,
      name: '4強賽',
      matches: [
        TournamentMatch(
          id: 'r1m0',
          teamA: teams[0],
          teamB: 'TBD',
          scoreA: 2,
          scoreB: 1,
          winner: teams[0],
        ),
        TournamentMatch(
          id: 'r1m1',
          teamA: teams[5],
          teamB: teams[6],
          scoreA: 1,
          scoreB: 3,
          winner: teams[6],
        ),
      ],
    );

    // 第三輪 (準決賽): 1 場比賽
    final round3 = TournamentRound(
      roundIndex: 2,
      name: '準決賽',
      matches: [TournamentMatch(id: 'r2m0', teamA: teams[0], teamB: teams[6])],
    );

    // 第四輪 (決賽): 1 場比賽
    final round4 = TournamentRound(
      roundIndex: 3,
      name: '決賽',
      matches: [TournamentMatch(id: 'r3m0', teamA: '勝者 1', teamB: '勝者 2')],
    );

    return TournamentBracket(
      name: '2025 世界錦標賽',
      rounds: [round1, round2, round3, round4],
    );
  }
}
