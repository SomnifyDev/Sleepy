//
//  AdviceView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 9/22/21.
//

import SwiftUI

enum AdviceType: String {
    case sleepImportanceAdvice
    case sleepImprovementAdvice
    case phasesAdvice
    case heartAdvice
}

struct AdviceView: View {

    @Binding private var showAdvice: Bool
    @State private var viewModel: AdviceViewModel
    private let sheetType: AdviceType

    init(sheetType: AdviceType, showAdvice: Binding<Bool>) {
        self.sheetType = sheetType
        _showAdvice = showAdvice
        viewModel = AdviceViewModel(
            navigationTitle: "",
            image: Image(systemName: "zzz"),
            mainTitle: "",
            firstText: "",
            secondaryTitle: "",
            secondText: ""
        )
    }

    var body: some View {
        NavigationView {
            GeometryReader { g in
                ScrollView {
                    VStack (alignment: .leading) {
                        viewModel.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: g.size.width, height: 300)

                        Text(viewModel.mainTitle)
                            .font(.title)
                            .bold()
                            .padding([.trailing, .leading])

                        Text(viewModel.firstText)
                            .padding([.trailing, .leading])
                            .padding(.top, 8)

                        Text(viewModel.secondaryTitle)
                            .font(.title)
                            .bold()
                            .padding([.top, .trailing, .leading])

                        Text(viewModel.secondText)
                            .padding([.trailing, .leading])
                            .padding(.top, 8)

                        Spacer()
                    }
                }
            }
            .onAppear {
                viewModel = AdviceViewModel(
                    navigationTitle: getNavigationTitle(),
                    image: Image(sheetType.rawValue),
                    mainTitle: getMainTitle(),
                    firstText: getFirstText(),
                    secondaryTitle: getSecondaryTitle(),
                    secondText: getSecondText()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarItems(trailing: Button(action: {
                showAdvice = false
            }, label: {
                Text("Done".localized)
                    .fontWeight(.regular)
            }))
        }
    }

    // MARK: Configuration methods

    private func getNavigationTitle() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return "Sleep importance".localized
        case .sleepImprovementAdvice:
            return "Sleep improvement".localized
        case .phasesAdvice:
            return "Phases and stages".localized
        case .heartAdvice:
            return "Heart and sleep".localized
        }
    }

    private func getMainTitle() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return "Why is sleep so important?".localized
        case .sleepImprovementAdvice:
            return "How to improve your sleep?".localized
        case .phasesAdvice:
            return "Sleep phases and stages".localized
        case .heartAdvice:
            return "Learn more about the importance of sleep for heart health.".localized
        }
    }

    private func getFirstText() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return """
                Bragging about how little sleep you require is no longer a thing. Thanks to evolving sleep science and the constant background hum of just how important sleep is, all those I-only-need-four-hours-badasses have to prove they’re cool another way. It shouldn’t be a newsflash that regular sleep—like eating and breathing—is essential for the body and brain to function properly and that bad things will happen if you are deprived of it.

                Sleep deprivation can cause a broad variety of medical conditions, spanning from memory loss to hypertension and heart disease to hardcore hallucinations. Along with stress levels and caloric intake, the number of hours you sleep will directly affect your mental and physical health, say researchers. Doctors, sleep foundations, and government health organizations say that to stay healthy and perform at their peak, adults should get 7 to 9 hours of sleep per night. “We need it for a lot of biological and physiological reasons, and psychological, too,” says licensed psychologist and sleep specialist Julie Kolzet, PhD “When I help my patients fix their sleep, their anxiety and depression get better.”
                """.localized
        case .sleepImprovementAdvice:
            return """
                Sleeping well directly affects your mental and physical health. Fall short and it can take a serious toll on your daytime energy, productivity, emotional balance, and even your weight. Yet many of us regularly toss and turn at night, struggling to get the sleep we need.

                Getting a good night’s sleep may seem like an impossible goal when you’re wide awake at 3 a.m., but you have much more control over the quality of your sleep than you probably realize. Just as the way you feel during your waking hours often hinges on how well you sleep at night, so the cure for sleep difficulties can often be found in your daily routine.

                Unhealthy daytime habits and lifestyle choices can leave you tossing and turning at night and adversely affect your mood, brain and heart health, immune system, creativity, vitality, and weight. But by experimenting with the following tips, you can enjoy better sleep at night, boost your health, and improve how you think and feel during the day.
                """.localized
        case .phasesAdvice:
            return """
                Like most other mammals, humans also show two types of sleep:

                — Rapid eye movement (REM sleep)
                — Non-rapid eye movement (NREM sleep)

                Both these types of sleep have distinct features when evaluated using electroencephalogram or EEG.

                EEG monitors the brain activities and electrical impulses within the brain during awake state and during sleep. REM and NREM sleep also differ from each other in terms of physical characteristics.

                For example, during REM sleep the frequent bursts of eye movement activity occur. During REM sleep the EEG shows patterns similar to those when the person is awake. Thus it is a paradoxical state of sleep when the brain appears to be awake in terms of EEG but the individual is in deep sleep.

                During NREM sleep there is decreased activation of the EEG. This is also called orthodox sleep. The brain appears to be calm.
                """.localized
        case .heartAdvice:
            return """
                Cardiovascular disease is proven to be the cause of 31% of all deaths worldwide. They are known to develop from poor diet, smoking, lack of physical activity, and inadequate sleep patterns. It is also known how food, nicotine, and a sedentary lifestyle affect the heart and blood vessels. But the effect of irregular sleep patterns has so far remained a mystery.
                """.localized
        }
    }

    private func getSecondaryTitle() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return "How does sleep make us function better?".localized
        case .sleepImprovementAdvice:
            return "Take some tips to sleep better".localized
        case .phasesAdvice:
            return ""
        case .heartAdvice:
            return "Take care of your sleep".localized
        }
    }

    private func getSecondText() -> String {
        let myAttributes1 = [ NSAttributedString.Key.foregroundColor: UIColor.green ]
        switch sheetType {
        case .sleepImportanceAdvice:
            return """
                Approximately a third of our lives is spent sleeping. Although the mechanics of sleep may differ among animals, most of them share our need for sleep—even insects and more simple-brained creatures. While no one is really sure of the biological reason for sleep, despite decades of research, most scientists agree that sleep is critical for physiological and mental health. Some researchers hypothesize that sleep allows the brain to shut down in order to process memories; others suggest that sleep helps regulate the body’s hormones. What we do know is that sleep deprivation adversely affects organs such as the brain, heart, and lungs as well as one’s metabolism, immune function, and tendency toward obesity.
                """.localized
        case .sleepImprovementAdvice:
            return """
                Getting in sync with your body’s natural sleep-wake cycle, or circadian rhythm, is one of the most important strategies for sleeping better. If you keep a regular sleep-wake schedule, you’ll feel much more refreshed and energized than if you sleep the same number of hours at different times, even if you only alter your sleep schedule by an hour or two.

                1. Try to go to sleep and get up at the same time every day. This helps set your body’s internal clock and optimize the quality of your sleep. Choose a bed time when you normally feel tired, so that you don’t toss and turn. If you’re getting enough sleep, you should wake up naturally without an alarm. If you need an alarm clock, you may need an earlier bedtime.

                2. Avoid sleeping in—even on weekends. The more your weekend/weekday sleep schedules differ, the worse the jetlag-like symptoms you’ll experience. If you need to make up for a late night, opt for a daytime nap rather than sleeping in. This allows you to pay off your sleep debt without disturbing your natural sleep-wake rhythm.

                3. Be smart about napping. While napping is a good way to make up for lost sleep, if you have trouble falling asleep or staying asleep at night, napping can make things worse. Limit naps to 15 to 20 minutes in the early afternoon.

                4. Start the day with a healthy breakfast. Among lots of other health benefits, eating a balanced breakfast can help sync up your biological clock by letting your body know that it’s time to wake up and get going. Skipping breakfast on the other hand, can delay your blood sugar rhythms, lower your energy, and increase your stress, factors that may disrupt sleep.

                5. Fight after-dinner drowsiness. If you get sleepy way before your bedtime, get off the couch and do something mildly stimulating, such as washing the dishes, calling a friend, or getting clothes ready for the next day. If you give in to the drowsiness, you may wake up later in the night and have trouble getting back to sleep.
                """.localized
        case .phasesAdvice:
            return ""
        case .heartAdvice:
            return """
                Scientists have identified an unexpected chemical reaction linking poor sleep to heart disease.

                Scientists conducted an experiment on mice that had been switched to a high-fat diet. The mice were divided into two groups, one of which was allowed to sleep and one of which was not. Researchers noticed: in sleepy mice, fat plaques formed in the blood vessels much faster and with greater intensity. Chemical processes that lead to accelerated clogging of blood vessels were revealed a little later. According to medics, it all starts with the malfunction of the hypothalamus - the area of the brain responsible for regulating sleep and producing the protein hypocretin. Insufficient sleep leads to a lack of this protein. And this increases the amount of a hormone called colony-stimulating factor, which speeds up the production of white blood cells. And white blood cells lead to the formation of plaques in the blood vessels and, therefore, to disease.

                Such a chain dependence. Even the researchers themselves were surprised to see hypocretins play such a large role in fatal heart disease. For the sake of interest, they gave mice supplements with hypocretins, and their health improved markedly. Of course, this may not work in the case of humans, but the scientists intend to do some more studies and give an accurate answer.

                Shall we wait? But one thing is already clear: you need to sleep tight, you need to get enough sleep. Insomnia, sleep disturbance is always excruciating. And so... good night.
                """.localized
        }
    }

}
