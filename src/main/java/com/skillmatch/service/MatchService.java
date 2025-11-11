package com.skillmatch.service;

import com.skillmatch.dto.MatchResultadoDTO;
import com.skillmatch.repository.HabilidadeRepository;
import com.skillmatch.repository.TrabalhadorRepository;
import com.skillmatch.repository.VagaRepository;
import lombok.extern.slf4j.Slf4j; // <-- IMPORT NECESSÁRIO
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j // <-- ADICIONADO PARA CORRIGIR O ERRO DO 'log'
public class MatchService {

    @Autowired
    private TrabalhadorRepository trabalhadorRepository;

    @Autowired
    private VagaRepository vagaRepository;

    @Autowired
    private HabilidadeRepository habilidadeRepository;

    @Autowired
    private TrilhaDetalhadaService trilhaDetalhadaService; // Assumindo que você tem este serviço

    public MatchResultadoDTO calcularCompatibilidade(Long idTrabalhador, Long idVaga) {
        log.info("Iniciando cálculo de compatibilidade para trabalhador {} e vaga {}", idTrabalhador, idVaga);
        // ... (Sua lógica de cálculo vai aqui) ...
        // Este é um exemplo mockado:
        return new MatchResultadoDTO(idVaga, "Vaga Exemplo", 75.0, List.of("Java"), List.of("Python"), "Recomendação de Trilha Mockada");
    }

    public List<MatchResultadoDTO> listarVagasCompativeis(Long idTrabalhador) {
        log.info("Listando vagas compatíveis para trabalhador {}", idTrabalhador);
        // ... (Sua lógica de listagem vai aqui) ...
        // Este é um exemplo mockado:
        return List.of(
            new MatchResultadoDTO(1L, "Vaga Exemplo 1", 80.0, List.of("Java"), List.of(), "Trilha Java"),
            new MatchResultadoDTO(2L, "Vaga Exemplo 2", 50.0, List.of("React"), List.of("Angular"), "Trilha Frontend")
        );
    }
}