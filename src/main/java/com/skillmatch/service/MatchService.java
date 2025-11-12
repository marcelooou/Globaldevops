public MatchResultadoDTO calcularCompatibilidade(Long idTrabalhador, Long idVaga) {
    log.info("Iniciando cálculo de compatibilidade para trabalhador {} e vaga {}", idTrabalhador, idVaga);

    // 1️⃣ Verifica se o trabalhador existe
    var trabalhadorOpt = trabalhadorRepository.findById(idTrabalhador);
    if (trabalhadorOpt.isEmpty()) {
        throw new RuntimeException("Trabalhador não encontrado: " + idTrabalhador);
    }

    // 2️⃣ Verifica se a vaga existe
    var vagaOpt = vagaRepository.findById(idVaga);
    if (vagaOpt.isEmpty()) {
        throw new RuntimeException("Vaga não encontrada: " + idVaga);
    }

    var trabalhador = trabalhadorOpt.get();
    var vaga = vagaOpt.get();

    // 3️⃣ Calcula compatibilidade simples com base nas habilidades
    long totalHabilidades = vaga.getHabilidadesExigidas().size();
    long habilidadesEmComum = trabalhador.getHabilidades().stream()
            .filter(h -> vaga.getHabilidadesExigidas().contains(h))
            .count();

    double percentualCompatibilidade = ((double) habilidadesEmComum / totalHabilidades) * 100.0;

    // 4️⃣ Define status com base no percentual
    String status;
    if (percentualCompatibilidade >= 80.0) {
        status = "COMPATIVEL";
    } else if (percentualCompatibilidade >= 50.0) {
        status = "PARCIALMENTE_COMPATIVEL";
    } else {
        status = "INCOMPATIVEL";
    }

    // 5️⃣ Monta o resultado conforme o DTO esperado
    MatchResultadoDTO dto = new MatchResultadoDTO();
    dto.setIdTrabalhador(idTrabalhador);
    dto.setIdVaga(idVaga);
    dto.setPercentualCompatibilidade(percentualCompatibilidade);
    dto.setStatusMatch(status);
    dto.setMensagem("Cálculo automático de compatibilidade executado com sucesso.");
    dto.setTrilhaRecomendada("Trilha gerada automaticamente.");

    return dto;
}
