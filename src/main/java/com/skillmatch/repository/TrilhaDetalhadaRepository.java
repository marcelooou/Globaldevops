package com.skillmatch.repository;

import com.skillmatch.document.TrilhaDetalhada;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface TrilhaDetalhadaRepository extends MongoRepository<TrilhaDetalhada, String> {

    Optional<TrilhaDetalhada> findByIdTrilhaRelacional(Long idTrilhaRelacional);

    List<TrilhaDetalhada> findByStatus(String status);

    List<TrilhaDetalhada> findByTituloTrilhaContainingIgnoreCase(String titulo);
}
