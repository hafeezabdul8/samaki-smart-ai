from django.core.management.base import BaseCommand
from core.models import FishSpecies, User

class Command(BaseCommand):
    help = 'Seed database with species and admin user'

    def handle(self, *args, **options):
        # Create species
        species_data = [
            {'name_en': 'Rabbitfish', 'name_sw': 'Tasi', 'scientific_name': 'Siganus sutor', 'status': 'green', 'note': 'Common reef fish. Sustainable catch. High market demand.'},
            {'name_en': 'Parrotfish', 'name_sw': 'Pono', 'scientific_name': 'Scarus ghobban', 'status': 'red', 'note': 'Critical for reef health. Overfished. Consider Snapper as alternative.'},
            {'name_en': 'Snapper', 'name_sw': 'Changu', 'scientific_name': 'Lutjanus fulviflamma', 'status': 'green', 'note': 'Abundant. Sustainable catch. Popular in hotels and restaurants.'},
            {'name_en': 'Grouper', 'name_sw': 'Chewa', 'scientific_name': 'Epinephelus spp.', 'status': 'amber', 'note': 'High value. Monitor catch levels. Important for tourism sector.'},
            {'name_en': 'Goatfish', 'name_sw': 'Mkundaji', 'scientific_name': 'Parupeneus spp.', 'status': 'green', 'note': 'Common in local markets. Stable population.'},
            {'name_en': 'Surgeonfish', 'name_sw': 'Puju/Kangaja', 'scientific_name': 'Acanthurus spp.', 'status': 'green', 'note': 'Reef fish. Sustainable. Good for local consumption.'},
            {'name_en': 'Mullet', 'name_sw': 'Mkizi', 'scientific_name': 'Mugil cephalus', 'status': 'green', 'note': 'Coastal species. Abundant. Important for food security.'},
            {'name_en': 'Anchovy', 'name_sw': 'Dagaa', 'scientific_name': 'Stolephorus commersonnii', 'status': 'green', 'note': 'Very abundant. Key food source and export product.'},
            {'name_en': 'Sardine', 'name_sw': 'Saradini', 'scientific_name': 'Sardinella spp.', 'status': 'green', 'note': 'Pelagic species. Abundant. Good for local markets.'},
            {'name_en': 'Mackerel', 'name_sw': 'Vibua', 'scientific_name': 'Rastrelliger kanagurta', 'status': 'green', 'note': 'Pelagic fish. Stable population. Popular in local cuisine.'},
            {'name_en': 'Trevally', 'name_sw': 'Kolekole/Karambisi', 'scientific_name': 'Carangoides spp.', 'status': 'amber', 'note': 'Reef predator. Monitor stock levels.'},
            {'name_en': 'Yellowfin Tuna', 'name_sw': 'Jodari', 'scientific_name': 'Thunnus albacares', 'status': 'amber', 'note': 'Popular export fish. High demand. Avoid catching juveniles.'},
            {'name_en': 'Swordfish', 'name_sw': 'Nduaro/Mbasi', 'scientific_name': 'Xiphias gladius', 'status': 'amber', 'note': 'Deep sea species. High value for export.'},
            {'name_en': 'Kingfish', 'name_sw': 'Nguru/Kanadi', 'scientific_name': 'Scomberomorus commerson', 'status': 'amber', 'note': 'High value pelagic fish. Monitor catch levels.'},
            {'name_en': 'Barracuda', 'name_sw': 'Mzia', 'scientific_name': 'Sphyraena barracuda', 'status': 'amber', 'note': 'Predatory fish. Seasonal migration.'},
            {'name_en': 'Shark/Ray', 'name_sw': 'Papa/Taa', 'scientific_name': 'Elasmobranchii', 'status': 'red', 'note': 'Protected species. Critical for marine ecosystem.'},
            {'name_en': 'Octopus/Squid', 'name_sw': 'Pweza/Ngisi', 'scientific_name': 'Octopus cyanea / Loligo spp.', 'status': 'amber', 'note': 'Important for export. Seasonal limits apply.'},
            {'name_en': 'Lobster', 'name_sw': 'Kamba', 'scientific_name': 'Panulirus spp.', 'status': 'amber', 'note': 'High value export product. Premium pricing.'},
        ]
        
        for s in species_data:
            FishSpecies.objects.get_or_create(name_en=s['name_en'], defaults=s)
        
        # Create admin user
        if not User.objects.filter(username='admin1').exists():
            User.objects.create_superuser(
                username='admin1',
                email='admin@samaki.co.tz',
                password='Admin@2026',
                role='admin',
                phone='0770000000'
            )
            self.stdout.write('Admin created')
        
        # Create test users
        if not User.objects.filter(username='hotel1').exists():
            User.objects.create_user(username='hotel1', password='test1234', role='hotel_buyer', phone='0771111111', hotel_name='Zanzibar Beach Resort', location='Stone Town')
        if not User.objects.filter(username='fisherman1').exists():
            User.objects.create_user(username='fisherman1', password='test1234', role='fisherman', phone='0772222222', market='Malindi Market', location='Malindi')
        
        self.stdout.write(self.style.SUCCESS(f'Done! {FishSpecies.objects.count()} species, users created'))
