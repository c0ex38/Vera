import SwiftUI

// Bu dosya artık onboarding adımlarının ana konteynırı görevini görüyor.
// Her bir adım kendi dosyasına (Views/Onboarding/Steps/) taşındı.

// Not: Bu dosya isterseniz silinebilir ve adımlar doğrudan OnboardingView içinde
// switch-case ile çağrılabilir. Ancak şimdilik yapısal bütünlük için
// bu "Sanal" görünüm yapılarını burada tutuyoruz (veya import ediyoruz).

// OnboardingView.swift dosyasının bu adımlara erişebilmesi için
// adımların 'public' veya aynı modülde olması yeterlidir.
