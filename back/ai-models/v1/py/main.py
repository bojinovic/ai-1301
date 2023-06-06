import json, random

seed = random.randint(0, 2**256-1)

packedData = random.randint(0, 2**256-1)

with open('decision.json', 'w') as f:
    f.write(
        json.dumps(
            {
                "seed": str(seed),
                "packedData": str(packedData)
            }
        )
    )
