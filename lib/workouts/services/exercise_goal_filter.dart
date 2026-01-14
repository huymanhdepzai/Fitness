class ExerciseGoalFilter {
  static Set<String> musclesForGoal(String? goal) {
    switch (goal) {
      case 'lose_fat':
        return {
          'cardiovascular system',
          'core', 'abs', 'abdominals', 'lower abs', 'obliques',
          'glutes', 'quads', 'quadriceps', 'hamstrings', 'calves',
          'back', 'lats', 'latissimus dorsi',
          'shoulders', 'deltoids',
        };
      case 'lean_tone':
        return {
          'abs', 'abdominals', 'obliques', 'core',
          'biceps', 'triceps', 'forearms',
          'shoulders', 'deltoids', 'traps', 'trapezius',
          'back', 'upper back', 'lats', 'latissimus dorsi', 'rhomboids',
          'chest', 'pectorals',
        };
      case 'improve_shape':
      default:
        return {
          'glutes', 'quads', 'quadriceps', 'hamstrings', 'calves',
          'core', 'abs', 'abdominals', 'obliques',
          'back', 'lats', 'latissimus dorsi',
          'chest', 'pectorals',
          'shoulders', 'deltoids',
        };
    }
  }

  static Set<String> bodyPartsForGoal(String? goal) {
    switch (goal) {
      case 'lose_fat':
        return {'cardio', 'upper legs', 'waist', 'back'};
      case 'lean_tone':
        return {'upper arms', 'shoulders', 'chest', 'back', 'waist', 'lower arms'};
      case 'improve_shape':
      default:
        return {'upper legs', 'waist', 'back', 'chest', 'shoulders', 'upper arms'};
    }
  }
}
