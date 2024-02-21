import SwiftUI

enum ExerciseType: String, CaseIterable {
    case squat = "Agachamento"
    case benchPress = "Supino"
    case deadlift = "Levantamento Terra"
    case pushUp = "Flexão de Braço"
    case shoulderPress = "Desenvolvimento"
}

class ExerciseSelection: ObservableObject {
    @Published var selectedExercise: ExerciseType?
    @Published var count: Int = 0
    static let shared = ExerciseSelection()
}

struct ExerciseCard: View {
    var exerciseType: ExerciseType

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 150, height: 150)
            .foregroundColor(Color.blue)
            .overlay(
                Text(exerciseType.rawValue)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            )
            .onTapGesture {
                ExerciseSelection.shared.selectedExercise = exerciseType
                ExerciseSelection.shared.count += 1
            }
    }
}

struct MainView: View {
    @StateObject var exerciseSelection = ExerciseSelection.shared

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(ExerciseType.allCases, id: \.self) { exerciseType in
                        NavigationLink(destination: CountingView(), tag: exerciseType, selection: $exerciseSelection.selectedExercise) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())

                        ExerciseCard(exerciseType: exerciseType)
                    }
                }
                .padding()
            }
//            .navigationTitle(" ") //Retira o "back" no botao voltar da proxima tela
            .environmentObject(exerciseSelection)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
