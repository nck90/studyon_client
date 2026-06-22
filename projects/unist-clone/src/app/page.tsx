import { Header } from "@/components/Header";
import { HeroSection } from "@/components/HeroSection";
import { UnistToday } from "@/components/UnistToday";
import { InfoForUnistar } from "@/components/InfoForUnistar";
import { WhyUnist } from "@/components/WhyUnist";
import { ResearchImpact } from "@/components/ResearchImpact";
import { LifeAtUnist } from "@/components/LifeAtUnist";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <HeroSection />
        <UnistToday />
        <InfoForUnistar />
        <WhyUnist />
        <ResearchImpact />
        <LifeAtUnist />
      </main>
      <Footer />
    </>
  );
}
