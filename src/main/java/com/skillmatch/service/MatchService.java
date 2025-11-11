package com.skillmatch.service;

import com.skillmatch.dto.MatchResultadoDTO;
import com.skillmatch.entity.Trabalhador;
import com.skillmatch.entity.Vaga;
import com.skillmatch.repository.TrabalhadorRepository;
import com.skillmatch.repository.VagaRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@Transactional(readOnly = true)
public class MatchService {

    @Autowired
    private TrabalhadorRepository trabalhadorRepository;

    @Autowired
    private VagaRepository vagaRepository;

    @Autowired
    private TrilhaDetalhadaService trilhaService;

    /**
     * Calcula a compatibilidade entre um trabalhador e uma vaga
     * Baseado no percentual de habilidades que o trabalhador possui
     * em relação às habilidades exigidas pela vaga
     */
    public MatchResultadoDTO calcularCompatibilidade(Long idTrabalhador, Long idVaga) {
        log.info("Calculando compatibilidade entre trabalhador {} e vaga {}", idTrabalhador, idVaga);

        Trabalhador trabalhador = trabalhadorRepository.findById(idTrabalhador)
                .orElseThrow(() -> new RuntimeException("Trabalhador não encontrado"));

        Vaga vaga = vagaRepository.findById(idVaga)
                .orElseThrow(() -> new RuntimeException("Vaga não encontrada"));

        double compatibilidade = calcularPercentualCompatibilidade(trabalhador, vaga);

        MatchResultadoDTO resultado = new MatchResultadoDTO();
        resultado.setIdTrabalhador(idTrabalhador);
        resultado.setIdVaga(idVaga);
        resultado.setPercentualCompatibilidade(compatibilidade);

        if (compatibilidade >= 80) {
            resultado.setStatusMatch("COMPATIVEL");
            resultado.setMensagem("Excelente compatibilidade! Você atende aos requisitos da vaga.");
        } else if (compatibilidade >= 50) {
            resultado.setStatusMatch("PARCIALMENTE_COMPATIVEL");
            resultado.setMensagem("Compatibilidade parcial. Recomendamos uma trilha de aprendizado para melhorar suas habilidades.");
            resultado.setTrilhaRecomendada(recomendarTrilha(vaga));
        } else {
            resultado.setStatusMatch("INCOMPATIVEL");
            resultado.setMensagem("Compatibilidade baixa. Sugerimos uma trilha de aprendizado completa.");
            resultado.setTrilhaRecomendada(recomendarTrilha(vaga));
        }

        log.info("Compatibilidade calculada: {}%", compatibilidade);
        return resultado;
    }

    /**
     * Lista todas as vagas compatíveis para um trabalhador
     */
    public List<MatchResultadoDTO> listarVagasCompativeis(Long idTrabalhador) {
        log.info("Listando vagas compatíveis para trabalhador {}", idTrabalhador);

        return vagaRepository.findAll().stream()
                .map(vaga -> calcularCompatibilidade(idTrabalhador, vaga.getIdVaga()))
                .filter(match -> match.getPercentualCompatibilidade() >= 50)
                .collect(Collectors.toList());
    }

    /**
     * Calcula o percentual de compatibilidade entre trabalhador e vaga
     * Fórmula: (habilidades que o trabalhador possui / habilidades exigidas pela vaga) * 100
     */
    private double calcularPercentualCompatibilidade(Trabalhador trabalhador, Vaga vaga) {
        if (vaga.getHabilidadesExigidas() == null || vaga.getHabilidadesExigidas().isEmpty()) {
            return 100.0;
        }

        long habilidadesExigidas = vaga.getHabilidadesExigidas().size();
        long habilidadesAtendidas = vaga.getHabilidadesExigidas().stream()
                .filter(habilidade -> trabalhador.getHabilidades().contains(habilidade))
                .count();

        return (double) (habilidadesAtendidas * 100) / habilidadesExigidas;
    }

    /**
     * Recomenda uma trilha de aprendizado baseada nas habilidades exigidas pela vaga
     */
    private String recomendarTrilha(Vaga vaga) {
        try {
            return trilhaService.recomendarTrilhaPorHabilidades(vaga.getHabilidadesExigidas());
        } catch (Exception e) {
            log.warn("Erro ao recomendar trilha: {}", e.getMessage());
            return "Trilha não disponível no momento";
        }
    }
}
