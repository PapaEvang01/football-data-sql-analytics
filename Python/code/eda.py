import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# ============================================================
# FILE PATHS
# ============================================================
OVERALL_PATH = "data/04_01.csv"
TEAM_PATH = "data/04_02.csv"
MATCHUP_PATH = "data/04_03_matchup_summary.csv"


# ============================================================
# OUTPUT FOLDERS
# ============================================================
GENERAL_DIR = "results/figures/01_general"
TEAM_DIR = "results/figures/02_team_perf"
MATCHUP_DIR = "results/figures/03_matchup"


# ============================================================
# GENERAL FUNCTIONS
# ============================================================
def create_output_folders():
    """Create structured output folders."""
    os.makedirs(GENERAL_DIR, exist_ok=True)
    os.makedirs(TEAM_DIR, exist_ok=True)
    os.makedirs(MATCHUP_DIR, exist_ok=True)


def load_csv(file_path, name):
    """Load a CSV file and return a DataFrame."""
    try:
        df = pd.read_csv(file_path)
        print(f"[OK] {name} loaded successfully.")
        return df
    except Exception as e:
        print(f"[ERROR] Failed to load {name}: {e}")
        return None


def print_basic_info(df, name):
    """Print basic information about a DataFrame."""
    if df is None:
        print(f"[WARNING] {name} is None.")
        return

    print("\n" + "=" * 60)
    print(name)
    print("=" * 60)

    print(f"Shape: {df.shape}")

    print("\nColumns:")
    print(df.columns.tolist())

    print("\nMissing values:")
    print(df.isnull().sum())

    print("\nFirst 5 rows:")
    print(df.head())


def format_label(value):
    """Format chart labels with integers or two decimal places."""
    return f"{int(value)}" if float(value).is_integer() else f"{value:.2f}"


# ============================================================
# 04_01.csv - OVERALL DATASET ANALYSIS
# ============================================================
def analyze_overall(overall_df):
    """Create a dashboard-style chart for overall dataset metrics."""

    if overall_df is None:
        print("[WARNING] Overall Summary is missing.")
        return

    print("\n" + "=" * 60)
    print("OVERALL DATASET ANALYSIS")
    print("=" * 60)

    df = overall_df.copy()
    df["value"] = pd.to_numeric(df["value"], errors="coerce")
    numeric_df = df.dropna().copy()

    print("\nNumeric Metrics Used for Plot:")
    print(numeric_df)

    plt.figure(figsize=(10, 6))
    bars = plt.barh(numeric_df["metric"], numeric_df["value"])

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            format_label(width),
            va="center"
        )

    plt.title("Dataset Overview")
    plt.xlabel("Value")
    plt.ylabel("Metric")
    plt.tight_layout()

    plt.savefig(os.path.join(GENERAL_DIR, "overall_dashboard.png"))
    plt.show()


# ============================================================
# 04_02.csv - TEAM PERFORMANCE ANALYSIS
# ============================================================
def plot_top_teams(team_df, column, title, filename):
    """Create a horizontal bar chart for top 10 teams by a selected metric."""

    top = team_df.sort_values(by=column, ascending=False).head(10)

    plt.figure(figsize=(10, 6))
    bars = plt.barh(top["team"], top[column])
    plt.gca().invert_yaxis()

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            format_label(width),
            va="center"
        )

    plt.title(title)
    plt.xlabel(column)
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, filename))
    plt.show()


def plot_home_vs_away_win_rate(team_df):
    """Compare home and away win rates for the top teams by win rate."""

    top_teams = team_df.sort_values(by="win_rate_pct", ascending=False).head(10)

    plt.figure(figsize=(10, 6))

    x = range(len(top_teams))

    plt.bar(
        x,
        top_teams["home_win_rate_pct"],
        width=0.4,
        label="Home Win %",
        align="center"
    )

    plt.bar(
        [i + 0.4 for i in x],
        top_teams["away_win_rate_pct"],
        width=0.4,
        label="Away Win %"
    )

    plt.xticks(
        [i + 0.2 for i in x],
        top_teams["team"],
        rotation=45,
        ha="right"
    )

    plt.title("Home vs Away Win Rate (Top Teams)")
    plt.ylabel("Win Rate (%)")
    plt.legend()
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, "home_vs_away_win_rate.png"))
    plt.show()


def plot_attacking_vs_defensive(team_df):
    """Scatter plot: attacking power vs defensive performance."""

    plt.figure(figsize=(10, 6))

    plt.scatter(
        team_df["avg_goals_scored"],
        team_df["avg_goals_conceded"]
    )

    for _, row in team_df.iterrows():
        plt.text(
            row["avg_goals_scored"] + 0.01,
            row["avg_goals_conceded"] + 0.01,
            row["team"],
            fontsize=8
        )

    plt.title("Attacking vs Defensive Team Profile")
    plt.xlabel("Average Goals Scored")
    plt.ylabel("Average Goals Conceded")
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, "teams_attack_vs_defense_scatter.png"))
    plt.show()


def plot_winrate_vs_goaldiff(team_df):
    """Scatter plot: win rate vs average goal difference."""

    plt.figure(figsize=(10, 6))

    plt.scatter(
        team_df["avg_goal_difference"],
        team_df["win_rate_pct"]
    )

    for _, row in team_df.iterrows():
        plt.text(
            row["avg_goal_difference"] + 0.02,
            row["win_rate_pct"] + 0.2,
            row["team"],
            fontsize=8
        )

    plt.title("Win Rate vs Goal Difference")
    plt.xlabel("Average Goal Difference")
    plt.ylabel("Win Rate (%)")
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, "winrate_vs_goaldiff.png"))
    plt.show()


def plot_team_correlation_heatmap(team_df):
    """Correlation heatmap for key team performance metrics."""

    columns = [
        "total_wins",
        "win_rate_pct",
        "avg_goals_scored",
        "avg_goals_conceded",
        "avg_goal_difference"
    ]

    corr_df = team_df[columns].corr()

    plt.figure(figsize=(8, 6))
    sns.heatmap(corr_df, annot=True, cmap="coolwarm", fmt=".2f")

    plt.title("Correlation Heatmap of Team Performance Metrics")
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, "team_correlation_heatmap.png"))
    plt.show()


def plot_home_away_heatmap(team_df):
    """Correlation heatmap for home vs away performance metrics."""

    columns = [
        "home_win_rate_pct",
        "home_draw_rate_pct",
        "home_loss_rate_pct",
        "away_win_rate_pct",
        "away_draw_rate_pct",
        "away_loss_rate_pct"
    ]

    corr_df = team_df[columns].corr()

    plt.figure(figsize=(8, 6))
    sns.heatmap(corr_df, annot=True, cmap="coolwarm", fmt=".2f")

    plt.title("Home vs Away Performance Correlation")
    plt.tight_layout()

    plt.savefig(os.path.join(TEAM_DIR, "home_away_correlation.png"))
    plt.show()


def analyze_teams(team_df):
    """Analyze team performance with ranking charts, scatter plots, and heatmaps."""

    if team_df is None:
        print("[WARNING] Team Summary is missing.")
        return

    print("\n" + "=" * 60)
    print("TEAM ANALYSIS")
    print("=" * 60)

    plot_top_teams(
        team_df,
        "total_wins",
        "Top 10 Teams by Total Wins",
        "teams_top_wins.png"
    )

    plot_top_teams(
        team_df,
        "win_rate_pct",
        "Top 10 Teams by Win Rate (%)",
        "teams_win_rate.png"
    )

    plot_top_teams(
        team_df,
        "avg_goals_scored",
        "Top 10 Teams by Avg Goals Scored",
        "teams_avg_goals.png"
    )

    plot_top_teams(
        team_df,
        "avg_goal_difference",
        "Top 10 Teams by Goal Difference",
        "teams_goal_diff.png"
    )

    plot_home_vs_away_win_rate(team_df)
    plot_attacking_vs_defensive(team_df)
    plot_winrate_vs_goaldiff(team_df)
    plot_team_correlation_heatmap(team_df)
    plot_home_away_heatmap(team_df)


# ============================================================
# 04_03_matchup_summary.csv - BIG 5 MATCHUP ANALYSIS
# ============================================================
def analyze_matchups(matchup_df):
    """Analyze matchups only between selected Big 5 clubs."""

    if matchup_df is None:
        print("[WARNING] Matchup Summary is missing.")
        return

    print("\n" + "=" * 60)
    print("BIG 5 MATCHUP ANALYSIS")
    print("=" * 60)

    big_teams = [
        "Arsenal",
        "Manchester City",
        "Manchester United",
        "Chelsea",
        "Liverpool"
    ]

    # Keep only matchups where BOTH teams are in the Big 5 list
    df_big = matchup_df[
        matchup_df["team_1"].isin(big_teams) &
        matchup_df["team_2"].isin(big_teams)
    ].copy()

    df_big["matchup"] = df_big["team_1"] + " vs " + df_big["team_2"]

    print(f"\nTotal Big 5 Matchups Analyzed: {len(df_big)}")
    print(df_big[["matchup", "total_matches", "avg_goals", "avg_fouls", "avg_shots", "avg_corners"]])

    plot_big5_goals(df_big)
    plot_big5_intensity(df_big)
    plot_big5_heatmap(df_big)
    plot_big5_dominance(df_big)

def plot_big5_goals(df_big):
    """Plot average goals for Big 5 matchups."""

    top = df_big.sort_values(by="avg_goals", ascending=False)

    plt.figure(figsize=(10, 6))
    bars = plt.barh(top["matchup"], top["avg_goals"])
    plt.gca().invert_yaxis()

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            format_label(width),
            va="center"
        )

    plt.title("Big 5 Matchups - Average Goals")
    plt.xlabel("Average Goals")
    plt.tight_layout()

    plt.savefig(os.path.join(MATCHUP_DIR, "big5_avg_goals.png"))
    plt.show()


def plot_big5_intensity(df_big):
    """Plot intensity score for Big 5 matchups."""

    df_big = df_big.copy()

    df_big["intensity_score"] = (
        df_big["avg_fouls"]
        + df_big["avg_yellow_cards"]
        + df_big["avg_red_cards"] * 2
    )

    top = df_big.sort_values(by="intensity_score", ascending=False)

    plt.figure(figsize=(10, 6))
    bars = plt.barh(top["matchup"], top["intensity_score"])
    plt.gca().invert_yaxis()

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            format_label(width),
            va="center"
        )

    plt.title("Big 5 Matchups - Intensity Score")
    plt.xlabel("Intensity Score")
    plt.tight_layout()

    plt.savefig(os.path.join(MATCHUP_DIR, "big5_intensity_score.png"))
    plt.show()


def plot_big5_heatmap(df_big):
    """Create a heatmap for Big 5 matchup metrics."""

    columns = [
        "avg_goals",
        "avg_fouls",
        "avg_shots",
        "avg_corners"
    ]

    heatmap_data = df_big.set_index("matchup")[columns]

    plt.figure(figsize=(10, 6))
    sns.heatmap(
        heatmap_data,
        annot=True,
        cmap="coolwarm",
        fmt=".2f"
    )

    plt.title("Big 5 Matchup Performance Overview")
    plt.tight_layout()

    plt.savefig(os.path.join(MATCHUP_DIR, "big5_matchup_heatmap.png"))
    plt.show()

def plot_big5_dominance(df_big):
    """Show how dominant teams are in big matchups."""

    df = df_big.copy()

    df["dominance"] = abs(
        df["team_1_win_rate_pct"] - df["team_2_win_rate_pct"]
    )

    plt.figure(figsize=(10, 6))
    bars = plt.barh(df["matchup"], df["dominance"])
    plt.gca().invert_yaxis()

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            f"{width:.2f}",
            va="center"
        )

    plt.title("Big 5 Matchups - Win Dominance")
    plt.xlabel("Win Rate Difference (%)")
    plt.tight_layout()

    plt.savefig(os.path.join(MATCHUP_DIR, "big5_dominance.png"))
    plt.show()

# ============================================================
# MAIN
# ============================================================
def main():
    create_output_folders()

    overall_df = load_csv(OVERALL_PATH, "Overall Summary")
    team_df = load_csv(TEAM_PATH, "Team Summary")
    matchup_df = load_csv(MATCHUP_PATH, "Matchup Summary")

    print_basic_info(overall_df, "Overall Summary")
    print_basic_info(team_df, "Team Summary")
    print_basic_info(matchup_df, "Matchup Summary")

    analyze_overall(overall_df)
    analyze_teams(team_df)
    analyze_matchups(matchup_df)


if __name__ == "__main__":
    main()