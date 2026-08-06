import csv
from datetime import datetime
from django.core.management.base import BaseCommand
from core.models import FishSpecies, MarketPrice

class Command(BaseCommand):
    help = 'Load fish market data from CSV'

    def handle(self, *args, **options):
        file_path = 'samaki_smart_ai_dataset.csv'

        with open(file_path, 'r') as f:
            reader = csv.DictReader(f)
            count = 0

            for row in reader:
                species_name = row['species'].strip()

                # Get or create species
                species, created = FishSpecies.objects.get_or_create(
                    name_en=species_name,
                    defaults={'name_sw': species_name, 'status': 'green'}
                )

                # Create price record
                MarketPrice.objects.create(
                    species=species,
                    price_tzs=float(row['price_per_kg_tzs']),
                    tag='Fair Price',
                    recorded_at=datetime.strptime(row['date'], '%Y-%m-%d')
                )

                count += 1
                if count % 1000 == 0:
                    self.stdout.write(f'Loaded {count} rows...')

        self.stdout.write(self.style.SUCCESS(f'Done! Total: {count} rows loaded'))
        self.stdout.write(f'Species created: {FishSpecies.objects.count()}')
        self.stdout.write(f'Prices loaded: {MarketPrice.objects.count()}')
