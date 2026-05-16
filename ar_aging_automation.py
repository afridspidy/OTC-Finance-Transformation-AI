data = {
    'customer_name': [
        'Pacific Telco Ltd', 'Summit Corp', 'Apex Networks',
        'BlueStar Comms', 'Meridian Global', 'Northern Freight',
        'Delta Systems', 'Coastal Connect', 'Horizon Telecom', 'Pinnacle Corp'
    ],
    'invoice_number': [
        'INV-2024-001', 'INV-2024-002', 'INV-2024-003',
        'INV-2024-004', 'INV-2024-005', 'INV-2024-006',
        'INV-2024-007', 'INV-2024-008', 'INV-2024-009', 'INV-2024-010'
    ],
    'invoice_amount_usd': [
        15000, 42000, 8450, 21000, 5750,
        33000, 18750, 9200, 44000, 12500
    ],
    'days_outstanding': [12, 45, 67, 92, 8, 55, 101, 22, 78, 130],
    'match_status': [
        'Matched', 'Matched', 'Analyst Review', 'Suspense', 'Matched',
        'Analyst Review', 'Suspense', 'Matched', 'Matched', 'Suspense'
    ]
}

df = pd.DataFrame(data)

def assign_aging_bucket(days):
    if days <= 30:
        return '0-30 Days'
    elif days <= 60:
        return '31-60 Days'
    elif days <= 90:
        return '61-90 Days'
    else:
        return '90+ Days (Critical)'

df['aging_bucket'] = df['days_outstanding'].apply(assign_aging_bucket)


print("=" * 60)
print("AR AGING SUMMARY REPORT")
print(f"Generated: {datetime.now().strftime('%d-%b-%Y %H:%M')}")
print("=" * 60)

aging_summary = df.groupby('aging_bucket').agg(
    count=('invoice_number', 'count'),
    total_amount=('invoice_amount_usd', 'sum')
).reset_index()

print(aging_summary.to_string(index=False))
print()

print("=" * 60)
print("CRITICAL ITEMS — ACTION REQUIRED (90+ Days)")
print("=" * 60)

critical = df[df['days_outstanding'] > 90][
    ['customer_name', 'invoice_amount_usd', 'days_outstanding', 'match_status']
].sort_values('days_outstanding', ascending=False)

print(critical.to_string(index=False))
print()

total_ar = df['invoice_amount_usd'].sum()
matched_ar = df[df['match_status'] == 'Matched']['invoice_amount_usd'].sum()
collection_rate = (matched_ar / total_ar) * 100
avg_dso = df['days_outstanding'].mean()

print("=" * 60)
print("KEY METRICS")
print("=" * 60)
print(f"Total AR Outstanding:  ${total_ar:,.0f}")
print(f"Matched & Collected:   ${matched_ar:,.0f}")
print(f"Collection Rate:       {collection_rate:.1f}%")
print(f"Average DSO:           {avg_dso:.1f} days")
print(f"Items in Suspense:     {len(df[df['match_status'] == 'Suspense'])}")
