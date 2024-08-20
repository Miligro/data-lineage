import pandas as pd

file_path = 'predictions.csv'
df = pd.read_csv(file_path)

df['Weights'] = df['Weights'].apply(eval)
df['Pair'] = df['Pair'].apply(eval)

df['Weights'] = df['Weights'].apply(lambda x: tuple(x))

df_grouped = df.groupby('Weights').agg(
    sum_all_probabilities=('Probability', 'sum'),
    sum_two_largest_probabilities=('Probability', lambda x: x.nlargest(2).sum()),
    max_probabilities=('Probability', 'max')
).reset_index()

max_sum_all_probabilities = df_grouped.loc[df_grouped['sum_all_probabilities'].idxmax()]

max_sum_two_largest_probabilities = df_grouped.loc[df_grouped['sum_two_largest_probabilities'].idxmax()]

max_probabilities = df_grouped.loc[df_grouped['max_probabilities'].idxmax()]

best_weights_per_pair = df.loc[df.groupby('Pair')['Probability'].idxmax()]

target_pairs = [('staff', 'staff_first_shift'), ('departments', 'staff_first_shift')]

df_filtered = df[df['Pair'].isin(target_pairs)]

df_grouped_filtered = df_filtered.groupby('Weights').agg(
    sum_target_probabilities=('Probability', 'sum')
).reset_index()

max_sum_target_probabilities = df_grouped_filtered.loc[df_grouped_filtered['sum_target_probabilities'].idxmax()]

from itertools import combinations

pair_combinations = list(combinations(df['Pair'].unique(), 2))
max_sum_per_pair_combination = []

for pair1, pair2 in pair_combinations:
    df_filtered_comb = df[df['Pair'].isin([pair1, pair2])]
    df_grouped_comb = df_filtered_comb.groupby('Weights').agg(
        sum_comb_probabilities=('Probability', 'sum')
    ).reset_index()
    max_sum_comb_probabilities = df_grouped_comb.loc[df_grouped_comb['sum_comb_probabilities'].idxmax()]
    max_sum_per_pair_combination.append({
        'Pair1': pair1,
        'Pair2': pair2,
        'Weights': max_sum_comb_probabilities['Weights'],
        'Sum_Probability': max_sum_comb_probabilities['sum_comb_probabilities']
    })

max_sum_per_pair_combination_df = pd.DataFrame(max_sum_per_pair_combination)

print("Wektor wag z największą sumą prawdopodobieństw dla wszystkich par:")
print(max_sum_all_probabilities)

print("\nWektor wag z największą sumą dwóch największych prawdopodobieństw:")
print(max_sum_two_largest_probabilities)

print("\nWektor wag z największym prawdopodobieństwem:")
print(max_probabilities)

print("\nNajlepsze wagi dla każdej pary:")
print(best_weights_per_pair[['Pair', 'Weights', 'Probability']])

print("\nWektor wag z największą sumą prawdopodobieństw dla wybranych par:")
print(max_sum_target_probabilities)

print("\nMaksymalna suma prawdopodobieństw dla każdej pary par:")
print(max_sum_per_pair_combination_df)
